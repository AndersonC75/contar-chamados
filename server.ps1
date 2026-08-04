# Contador de Chamados — servidor local minimo.
# Serve o index.html no navegador e grava os chamados em chamados.json
# nesta mesma pasta (rede), a cada mudanca, sem dialogos.
# Inicie pelo "Abrir Contador.bat". Nao precisa instalar nada.

$ErrorActionPreference = 'Stop'
$root      = Split-Path -Parent $MyInvocation.MyCommand.Path
$dataFile  = Join-Path $root 'chamados.json'
$indexFile = Join-Path $root 'index.html'
$backupDir = Join-Path $root 'backups'
$port      = 8437

# Ja tem um servidor rodando nesta maquina? Entao so abre o navegador.
$jaRodando = $false
try {
  $tc = New-Object System.Net.Sockets.TcpClient
  $tc.Connect('127.0.0.1', $port)
  $tc.Close()
  $jaRodando = $true
} catch { $jaRodando = $false }
if ($jaRodando) {
  Start-Process "http://localhost:$port/"
  exit
}

$listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, $port)
$listener.Start()
Start-Process "http://localhost:$port/"

function Send-Http($stream, $status, $type, [byte[]]$body) {
  $header = "HTTP/1.1 $status`r`nContent-Type: $type`r`nContent-Length: $($body.Length)`r`nCache-Control: no-store`r`nConnection: close`r`n`r`n"
  $hb = [System.Text.Encoding]::ASCII.GetBytes($header)
  $stream.Write($hb, 0, $hb.Length)
  if ($body.Length -gt 0) { $stream.Write($body, 0, $body.Length) }
  $stream.Flush()
}

while ($true) {
  $client = $null
  try {
    $client = $listener.AcceptTcpClient()
    $client.ReceiveTimeout = 5000
    $stream = $client.GetStream()

    # le a requisicao inteira: cabecalhos + corpo (contando bytes, nao caracteres)
    $ms = New-Object System.IO.MemoryStream
    $buf = New-Object byte[] 16384
    $headerEnd = -1
    $contentLength = 0
    while ($true) {
      $n = $stream.Read($buf, 0, $buf.Length)
      if ($n -le 0) { break }
      $ms.Write($buf, 0, $n)
      $bytes = $ms.ToArray()
      if ($headerEnd -lt 0) {
        for ($i = 3; $i -lt $bytes.Length; $i++) {
          if ($bytes[$i-3] -eq 13 -and $bytes[$i-2] -eq 10 -and $bytes[$i-1] -eq 13 -and $bytes[$i] -eq 10) { $headerEnd = $i; break }
        }
        if ($headerEnd -ge 0) {
          $headText = [System.Text.Encoding]::ASCII.GetString($bytes, 0, $headerEnd + 1)
          if ($headText -match '(?im)^Content-Length:\s*(\d+)') { $contentLength = [int]$Matches[1] }
        }
      }
      if ($headerEnd -ge 0) {
        if (($ms.Length - ($headerEnd + 1)) -ge $contentLength) { break }
      }
    }
    if ($headerEnd -lt 0) { $client.Close(); continue }

    $bytes = $ms.ToArray()
    $headText = [System.Text.Encoding]::ASCII.GetString($bytes, 0, $headerEnd + 1)
    $requestLine = ($headText -split "`r`n")[0]
    $parts = $requestLine -split ' '
    $method = $parts[0]
    $path = $parts[1]
    $body = ''
    if ($contentLength -gt 0) {
      $body = [System.Text.Encoding]::UTF8.GetString($bytes, $headerEnd + 1, $contentLength)
    }

    if ($method -eq 'GET' -and ($path -eq '/' -or $path -eq '/index.html')) {
      $b = [System.IO.File]::ReadAllBytes($indexFile)
      Send-Http $stream '200 OK' 'text/html; charset=utf-8' $b
    }
    elseif ($method -eq 'GET' -and $path -eq '/api/load') {
      if (Test-Path $dataFile) { $b = [System.IO.File]::ReadAllBytes($dataFile) }
      else { $b = [System.Text.Encoding]::UTF8.GetBytes('[]') }
      Send-Http $stream '200 OK' 'application/json; charset=utf-8' $b
    }
    elseif ($method -eq 'POST' -and $path -eq '/api/save') {
      $valido = $false
      try {
        $null = $body | ConvertFrom-Json
        if ($body.Trim().StartsWith('[')) { $valido = $true }
      } catch {}
      if (-not $valido) {
        Send-Http $stream '400 Bad Request' 'application/json' ([System.Text.Encoding]::UTF8.GetBytes('{"ok":false}'))
      } else {
        if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir | Out-Null }
        # backup diario: antes da primeira gravacao do dia, guarda o estado anterior
        $daily = Join-Path $backupDir ('chamados_' + (Get-Date -Format 'yyyy-MM-dd') + '.json')
        if ((Test-Path $dataFile) -and -not (Test-Path $daily)) { Copy-Item $dataFile $daily }
        # gravacao atomica: escreve num temporario e troca
        $tmp = $dataFile + '.tmp'
        [System.IO.File]::WriteAllText($tmp, $body, (New-Object System.Text.UTF8Encoding($false)))
        Move-Item -Force $tmp $dataFile
        Send-Http $stream '200 OK' 'application/json' ([System.Text.Encoding]::UTF8.GetBytes('{"ok":true}'))
      }
    }
    else {
      Send-Http $stream '404 Not Found' 'text/plain' ([System.Text.Encoding]::UTF8.GetBytes('404'))
    }
  } catch {
    # erro numa conexao nao derruba o servidor; continua atendendo
  } finally {
    if ($client) { try { $client.Close() } catch {} }
  }
}
