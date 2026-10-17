#!/usr/bin/env python3
import os,sys,re,secrets,base64
from pathlib import Path
if len(sys.argv)!=3 or not re.fullmatch(r'[a-z][a-z0-9-]{2,39}',sys.argv[1]) or not re.fullmatch(r'(?=.{1,253}$)(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,63}',sys.argv[2]):
 raise SystemExit('Uso: python3 scripts/configure.py cliente-demo panel.tudominio.cl')
p=Path(__file__).resolve().parents[1]
v={'COMPOSE_PROJECT_NAME':'hefesto-analitica-'+sys.argv[1],'BI_HOST':sys.argv[2],'POSTGRES_HOST':'CONFIGURAR','POSTGRES_USERNAME':'metabase_app','POSTGRES_PASSWORD':secrets.token_hex(32),'MB_ENCRYPTION_SECRET_KEY':base64.b64encode(secrets.token_bytes(32)).decode(),'SUPABASE_DEDICATED_CONFIRMED':'false','SUPABASE_DATA_API_DISABLED':'false'}
try:fd=os.open(p/'.env',os.O_CREAT|os.O_EXCL|os.O_WRONLY,0o600)
except FileExistsError:raise SystemExit('.env existe; no se modifico')
with os.fdopen(fd,'w') as f:
 for k,value in v.items():f.write(f'{k}={value}\n')
print('.env generado. Completar host/login; asignar POSTGRES_PASSWORD al rol en Supabase y conservar clave de cifrado.')
