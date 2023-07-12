#!/bin/bash

if [[ -z "${PASSWORD}" ]]; then
  export PASSWORD="5c301bb8-6c77-41a0-a606-4ba11bbab084"
fi
echo ${PASSWORD}

export PASSWORD_JSON="$(echo -n "$PASSWORD" | jq -Rc)"

if [[ -z "${ENCRYPT}" ]]; then
  export ENCRYPT="chacha20-ietf-poly1305"
fi

if [[ -z "${V2_PATH}" ]]; then
  export ${V2_PATH}="s233"
fi
echo ${${V2_PATH}}

if [[ -z "${QR_PATH}" ]]; then
  export QR_PATH="/qr_img"
fi
echo ${QR_PATH}

case "$APPNAME" in
	*.*)
		export DOMAIN="$APPNAME"
		;;
	*)
		export DOMAIN="$APPNAME.herokuapp.com"
		;;
esac

bash /conf/shadowsocks-libev_config.json >  /etc/shadowsocks-libev/config.json
echo /etc/shadowsocks-libev/config.json
cat /etc/shadowsocks-libev/config.json

bash /conf/nginx_ss.conf > /etc/nginx/conf.d/ss.conf
echo /etc/nginx/conf.d/ss.conf
cat /etc/nginx/conf.d/ss.conf


if [ "$APPNAME" = "no" ]; then
  echo "Do not generate QR-code"
else
  [ ! -d /wwwroot/${QR_PATH} ] && mkdir /wwwroot/${QR_PATH}
  plugin=$(echo -n "v2ray;path=/${V2_PATH};host=${DOMAIN};tls" | sed -e 's/\//%2F/g' -e 's/=/%3D/g' -e 's/;/%3B/g')
  ss="ss://$(echo -n ${ENCRYPT}:${PASSWORD} | base64 -w 0)@${DOMAIN}:443?plugin=${plugin}" 
  echo "${ss}" | tr -d '\n' > /wwwroot/${QR_PATH}/index.html
  echo -n "${ss}" | qrencode -s 6 -o /wwwroot/${QR_PATH}/vpn.png
fi

ss-server -c /etc/shadowsocks-libev/config.json &
rm -rf /etc/nginx/sites-enabled/default
nginx -g 'daemon off;'
