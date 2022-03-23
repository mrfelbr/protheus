#CORRIGIDO: 
#1 - ESTAVA DELETANDO O WEBAPP.DLL DEIXANDO APENAS O APPSERVER.INI, AGORA FICA OS DOIS.
#2 - NA PASTA DO APPSERVER  QUANDO TINHA MAIS DE UM APPSERVER.EXE, O SCRIPT TRAVA NA HORA DE RENOMEAR O APPSERVER.EXE, AGORA O SCRIPT VAI DEIXAR APENAS 1 SE TIVER MAIS DE 1.
#3 - APPSERVER.EXE - MESMO PARANDO PELO COCKPIT PARAR TODOS OS SERVIÇOS, ALGUNS APPSERVER.EXE FICAVA ATIVO DEVIDO AO PRINTER.EXE TRAVADO NO SERVIDOR, CONSEQUENTEMENTE NAO ATUALIZAVA ESSE EXE PQ ESTA EM USO.
#4 - PRINTER.EXE EM USO, NAO ESTAVA SENDO ATUALIZADO, AGORA O SCRIPT FAZ UM TASKKILL EM TODOS OS PRINTER.EXE NA CORE E NAS SCALINGS



#ESSE SCRIPT ATUALIZA O BINARIO DA PLATAFORMA TCLOUD VERSAO DO SO - WINDOWS, COPIAR O SCRIPT PARA O SERVIDOR E EXECUTAR COM O POWERSHELL.



#O SCRIPT REPLICA O BINARIO QUE FOI ADICIONADO NA PASTA APP DA RAIZ DO PROTHEUS_DATA
#NO CAMINHO PROTHEUS_DATA\APP, NÃO IMPORTA A QUANTIDADE DE BALANCES O MESMO VAI REPLICAR PARA TODOS OS SERVIDORES.
#SCRIPT TAMBEM GERA BACKUP DA PASTA BIN ANTES DA ATUALIZACAO.
#AUTOR:FELIPE MORORO
#REVISADO:29/01/2020

#============= BACKUP BINARIO - INICIO =====================|
#===========================================================|

WRITE-HOST "REALIZANDO BACKUP DO BINARIO";Start-Sleep(5)

$Date=$(Get-Date -format yyyyMMddHHmmss)

$7ZIP = {C:\Program Files\7-Zip}
& $7ZIP\7z a -r D:\outsourcing\totvs\protheus\bin_$Date.zip D:\outsourcing\totvs\protheus\bin\appserver

#============= BACKUP BINARIO - FIM ========================|
#===========================================================|


#============= ATUALIZA BINARIO - INICIO ===================|
#===========================================================|

$TestPath=Test-Path "D:\outsourcing\totvs\protheus_data\app"
if($TestPath -eq "True"){
$AppCli="D:\outsourcing\totvs\protheus_data\app"
Get-ChildItem $AppCli -Include "webapp" -Directory -Recurse | Remove-Item -Force -Recurse
Get-ChildItem $AppCli -Include "*appserver*.ini","*.FCS","*.DMP",".FCS",".lnk" -Recurse | Remove-Item -Force -Recurse

#SE TIVER MAIS DE UM APPSERVER.EXE SERA EXCLUIDOS OS BACKUPS DOS MESMOS.
$AppCheck=Get-ChildItem -Path D:\outsourcing\totvs\protheus_data\app\ -Include "appserver*.exe" -Recurse
$AppTest=$AppCheck.count
if($AppTest -eq 1){"ok"}else{
For ($i=1; $i -lt $AppTest;$i++) {$AppRemove=$AppCheck[$i] | Remove-item -force}
}
$AppEXE=Get-ChildItem $AppCli -Include "appserver*.exe" -Recurse
$AppEXE | Rename-Item -NewName AppServer.exe

$balances=Get-Content -Path D:\outsourcing\totvs\protheus\bin\appserver_broker\appserver.ini | Select-String "6000"
$tempb=$balances | Select-String -NotMatch ";"
$balances=$tempb
$N=$balances.count
$i=0
For ($i=1; $i -lt $N;$i++) {$bl=[String]$balances[$i];$bl_especial=$bl.Substring(19);$bl_esp=$bl_especial -replace ("6000","");$bl_especial2=$bl_esp.TrimEnd()
WRITE-HOST ATUALIZANDO BINARIO DA ESPECIAL [$i];Start-Sleep(1)

taskkill /f /s $bl_especial2 -im "printer.exe"
Start-Sleep(1)
taskkill /f /s $bl_especial2 -im "appserver.exe"
Start-Sleep(1)
remove-item \\$bl_especial2\c$\outsourcing\totvs\protheus\bin\appserver -Exclude appserver.ini,webapp.dll -Recurse -force
remove-item \\$bl_especial2\c$\outsourcing\totvs\protheus\bin\appserver_2 -Exclude appserver.ini,webapp.dll -Recurse -force
remove-item \\$bl_especial2\c$\outsourcing\totvs\protheus\bin\appserver_3 -Exclude appserver.ini,webapp.dll -Recurse -force
remove-item \\$bl_especial2\c$\outsourcing\totvs\protheus\bin\appserver_4 -Exclude appserver.ini,webapp.dll -Recurse -force
Remove-Item \\$bl_especial2\c$\outsourcing\totvs\protheus\bin\appserver_coletor -Exclude appserver.ini,webapp.dll -Recurse -force
Remove-Item \\$bl_especial2\c$\outsourcing\totvs\protheus\bin\appserver_portal -Exclude appserver.ini,webapp.dll -Recurse -force
Remove-Item \\$bl_especial2\c$\outsourcing\totvs\protheus\bin\appserver_wsrest -Exclude appserver.ini,webapp.dll -Recurse -force
Remove-Item \\$bl_especial2\c$\outsourcing\totvs\protheus\bin\appserver_wssoap -Exclude appserver.ini,webapp.dll -Recurse -force
Remove-Item \\$bl_especial2\c$\\outsourcing\totvs\protheus\bin\appserver_grid -Exclude appserver.ini,webapp.dll -Recurse -force


robocopy D:\outsourcing\totvs\protheus_data\app \\$bl_especial2\c$\outsourcing\totvs\protheus\bin\appserver /w:1 /R:1 /e /z
robocopy D:\outsourcing\totvs\protheus_data\app \\$bl_especial2\c$\outsourcing\totvs\protheus\bin\appserver_2 /w:1 /R:1 /e /z
robocopy D:\outsourcing\totvs\protheus_data\app \\$bl_especial2\c$\outsourcing\totvs\protheus\bin\appserver_3 /w:1 /R:1 /e /z
robocopy D:\outsourcing\totvs\protheus_data\app \\$bl_especial2\c$\outsourcing\totvs\protheus\bin\appserver_4 /w:1 /R:1 /e /z
robocopy D:\outsourcing\totvs\protheus_data\app \\$bl_especial2\c$\outsourcing\totvs\protheus\bin\appserver_coletor /w:1 /R:1 /e /z
robocopy D:\outsourcing\totvs\protheus_data\app \\$bl_especial2\c$\outsourcing\totvs\protheus\bin\appserver_portal /w:1 /R:1 /e /z
robocopy D:\outsourcing\totvs\protheus_data\app \\$bl_especial2\c$\outsourcing\totvs\protheus\bin\appserver_wsrest /w:1 /R:1 /e /z
robocopy D:\outsourcing\totvs\protheus_data\app \\$bl_especial2\c$\outsourcing\totvs\protheus\bin\appserver_wssoap /w:1 /R:1 /e /z
robocopy D:\outsourcing\totvs\protheus_data\app \\$bl_especial2\c$\\outsourcing\totvs\protheus\bin\appserver_grid /w:1 /R:1 /e /z

}
WRITE-HOST "ATUALIZANDO BINARIO DA CORE";Start-Sleep(1)
#CORE BINARIO

Start-Sleep(1);
taskkill /f -im "printer.exe"
Start-Sleep(1)
taskkill /f -im "appserver.exe"

$AppCore=Get-ChildItem -Path D:\outsourcing\totvs\protheus\bin -Include appserver* -Attributes Directory -Recurse -Exclude "*cloud*"
$N=$AppCore.count
$i=0
For ($i=0; $i -lt $N;$i++) {$App=$AppCore[$i].fullname;
$app | Remove-Item -Exclude appserver.ini,webapp.dll -Recurse -force;


robocopy D:\outsourcing\totvs\protheus_data\app $App /w:1 /R:1 /e /z
Start-Sleep(1);
}
WRITE-HOST "ATUALIZACAO DO BINARIO FOI CONCLUIDO!";Start-Sleep(5);EXIT
}else{WRITE-HOST "NAO EXISTE PASTA APP NA RAIZ DO PROTHEUS_DATA!!";Start-Sleep(10);EXIT}



#=================== ATUALIZA BINARIO - FIM =======================|
#===========================================================|