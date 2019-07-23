#!/bin/bash

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Usage() {
	echo ""
	echo "Usage: ./createPeerAdminCard.sh [-h host] [-n]"
	echo ""
	echo "Options:"
	echo -e "\t-h or --host:\t\t(Optional) name of the host to specify in the connection profile"
	echo -e "\t-n or --noimport:\t(Optional) don't import into card store"
	echo ""
	echo "Example: ./createPeerAdminCard.sh"
	echo ""
	exit 1
}

Parse_Arguments() {
	while [ $# -gt 0 ]; do
		case $1 in
			--help)
				HELPINFO=true
				;;
			--host | -h)
                shift
				HOST="$1"
				;;
            --noimport | -n)
				NOIMPORT=true
				;;
		esac
		shift
	done
}

HOST=localhost
Parse_Arguments $@

if [ "${HELPINFO}" == "true" ]; then
    Usage
fi

# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "${HL_COMPOSER_CLI}" ]; then
  HL_COMPOSER_CLI=$(which composer)
fi

echo
# check that the composer command exists at a version >v0.16
COMPOSER_VERSION=$("${HL_COMPOSER_CLI}" --version 2>/dev/null)
COMPOSER_RC=$?

if [ $COMPOSER_RC -eq 0 ]; then
    AWKRET=$(echo $COMPOSER_VERSION | awk -F. '{if ($2<20) print "1"; else print "0";}')
    if [ $AWKRET -eq 1 ]; then
        echo Cannot use $COMPOSER_VERSION version of composer with fabric 1.2, v0.20 or higher is required
        exit 1
    else
        echo Using composer-cli at $COMPOSER_VERSION
    fi
else
    echo 'No version of composer-cli has been detected, you need to install composer-cli at v0.20 or higher'
    exit 1
fi

cat << EOF > DevServer_connection.json
{
    "name": "hlfv1",
    "x-type": "hlfv1",
    "x-commitTimeout": 300,
    "version": "1.0.0",
    "client": {
        "organization": "Org1",
        "connection": {
            "timeout": {
                "peer": {
                    "endorser": "300",
                    "eventHub": "300",
                    "eventReg": "300"
                },
                "orderer": "300"
            }
        }
    },
    "channels": {
        "mychannel": {
            "orderers": [
                "orderer.example.com"
            ],
            "peers": {
                "peer0.org1.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org1.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer0.org2.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org2.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                }
            }
        }
    },
    "organizations": {
        "Org1": {
            "mspid": "Org1MSP",
            "peers": [
                "peer0.org1.example.com",
                "peer1.org1.example.com"
            ],
            "certificateAuthorities": [
                "ca.org1.example.com"
            ]
        },
        "Org2": {
            "mspid": "Org2MSP",
            "peers": [
                "peer0.org2.example.com",
                "peer1.org2.example.com"
            ],
            "certificateAuthorities": [
                "ca.org2.example.com"
            ]
        }
    },
    "orderers": {
        "orderer.example.com": {
            "url": "grpcs://46.101.192.236:7050",
            "grpcOptions": {
                "ssl-target-name-override": "orderer.example.com"
            },
            "tlsCACerts": {
                "pem": "-----BEGIN CERTIFICATE-----\nMIICNDCCAdugAwIBAgIQEX3FVt8ZV5uIcBrEau4vrzAKBggqhkjOPQQDAjBsMQsw\nCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxMNU2FuIEZy\nYW5jaXNjbzEUMBIGA1UEChMLZXhhbXBsZS5jb20xGjAYBgNVBAMTEXRsc2NhLmV4\nYW1wbGUuY29tMB4XDTE5MDcyMzE0MzgzMFoXDTI5MDcyMDE0MzgzMFowbDELMAkG\nA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExFjAUBgNVBAcTDVNhbiBGcmFu\nY2lzY28xFDASBgNVBAoTC2V4YW1wbGUuY29tMRowGAYDVQQDExF0bHNjYS5leGFt\ncGxlLmNvbTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABIx07cYNC02aIhlrZXhu\n1JE5mg70wIKNn9TAsf6vi/YI0jF7tB3CbEYCfeAh9xYBH1w665GzBI5GJ3o71Vwo\nNo6jXzBdMA4GA1UdDwEB/wQEAwIBpjAPBgNVHSUECDAGBgRVHSUAMA8GA1UdEwEB\n/wQFMAMBAf8wKQYDVR0OBCIEIMaalUi86+2uEruiRC8KseeMXzxP2ipIMaEHstaj\npRo6MAoGCCqGSM49BAMCA0cAMEQCICEFwUGOReaYRys8Gkh0icUF9wzltdlXKNbk\nIgwuaC/YAiAqjezch503JPkBX/Ra3v6zDaRYtAoKONe7UK7zZHaqzg==\n-----END CERTIFICATE-----\n"
            }
        }
    },
    "peers": {
        "peer0.org1.example.com": {
            "url": "grpcs://46.101.192.236:7051",
            "eventUrl": "grpcs://46.101.192.236:7053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org1.example.com"
            },
            "tlsCACerts": {
                "pem": "-----BEGIN CERTIFICATE-----\nMIICSTCCAe+gAwIBAgIQKzF1l0yzWHI/18vP5TK/8zAKBggqhkjOPQQDAjB2MQsw\nCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxMNU2FuIEZy\nYW5jaXNjbzEZMBcGA1UEChMQb3JnMS5leGFtcGxlLmNvbTEfMB0GA1UEAxMWdGxz\nY2Eub3JnMS5leGFtcGxlLmNvbTAeFw0xOTA3MjMxNDM4MzBaFw0yOTA3MjAxNDM4\nMzBaMHYxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQH\nEw1TYW4gRnJhbmNpc2NvMRkwFwYDVQQKExBvcmcxLmV4YW1wbGUuY29tMR8wHQYD\nVQQDExZ0bHNjYS5vcmcxLmV4YW1wbGUuY29tMFkwEwYHKoZIzj0CAQYIKoZIzj0D\nAQcDQgAEn2u+EWT0mfMtrnUSOCj8CyFaCjct+XIcoJK7dvEUEWCYwpRnIaI96WZq\nnAWXkgmFKS8hph6PzZwWGjsRveQ6lKNfMF0wDgYDVR0PAQH/BAQDAgGmMA8GA1Ud\nJQQIMAYGBFUdJQAwDwYDVR0TAQH/BAUwAwEB/zApBgNVHQ4EIgQgS8PiaFfO1HDw\nwLDW+p28z5O22rOaAN8OrUzn5mB+uJ4wCgYIKoZIzj0EAwIDSAAwRQIhAKBvrxyi\n7k0O7UzVndf1JE9VUPn6mBJ1A98zRg9gMmV1AiAoQAt2RZhsFOvWj85+xh1YfcOy\n1UDWfgFd48T3/Z0o6Q==\n-----END CERTIFICATE-----\n"
            }
        },
        "peer1.org1.example.com": {
            "url": "grpcs://46.101.192.236:8051",
            "eventUrl": "grpcs://46.101.192.236:8053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org1.example.com"
            },
            "tlsCACerts": {
                "pem": "-----BEGIN CERTIFICATE-----\nMIICSTCCAe+gAwIBAgIQKzF1l0yzWHI/18vP5TK/8zAKBggqhkjOPQQDAjB2MQsw\nCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxMNU2FuIEZy\nYW5jaXNjbzEZMBcGA1UEChMQb3JnMS5leGFtcGxlLmNvbTEfMB0GA1UEAxMWdGxz\nY2Eub3JnMS5leGFtcGxlLmNvbTAeFw0xOTA3MjMxNDM4MzBaFw0yOTA3MjAxNDM4\nMzBaMHYxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQH\nEw1TYW4gRnJhbmNpc2NvMRkwFwYDVQQKExBvcmcxLmV4YW1wbGUuY29tMR8wHQYD\nVQQDExZ0bHNjYS5vcmcxLmV4YW1wbGUuY29tMFkwEwYHKoZIzj0CAQYIKoZIzj0D\nAQcDQgAEn2u+EWT0mfMtrnUSOCj8CyFaCjct+XIcoJK7dvEUEWCYwpRnIaI96WZq\nnAWXkgmFKS8hph6PzZwWGjsRveQ6lKNfMF0wDgYDVR0PAQH/BAQDAgGmMA8GA1Ud\nJQQIMAYGBFUdJQAwDwYDVR0TAQH/BAUwAwEB/zApBgNVHQ4EIgQgS8PiaFfO1HDw\nwLDW+p28z5O22rOaAN8OrUzn5mB+uJ4wCgYIKoZIzj0EAwIDSAAwRQIhAKBvrxyi\n7k0O7UzVndf1JE9VUPn6mBJ1A98zRg9gMmV1AiAoQAt2RZhsFOvWj85+xh1YfcOy\n1UDWfgFd48T3/Z0o6Q==\n-----END CERTIFICATE-----\n"
            }
        },
        "peer0.org2.example.com": {
            "url": "grpcs://178.128.204.29:7051",
            "eventUrl": "grpcs://178.128.204.29:7053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org2.example.com"
            },
            "tlsCACerts": {
                "pem": "-----BEGIN CERTIFICATE-----\nMIICSDCCAe+gAwIBAgIQNiiy6JpOsf2z1SvhXd2ASDAKBggqhkjOPQQDAjB2MQsw\nCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxMNU2FuIEZy\nYW5jaXNjbzEZMBcGA1UEChMQb3JnMi5leGFtcGxlLmNvbTEfMB0GA1UEAxMWdGxz\nY2Eub3JnMi5leGFtcGxlLmNvbTAeFw0xOTA3MjMxNDM4MzBaFw0yOTA3MjAxNDM4\nMzBaMHYxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQH\nEw1TYW4gRnJhbmNpc2NvMRkwFwYDVQQKExBvcmcyLmV4YW1wbGUuY29tMR8wHQYD\nVQQDExZ0bHNjYS5vcmcyLmV4YW1wbGUuY29tMFkwEwYHKoZIzj0CAQYIKoZIzj0D\nAQcDQgAEKfOi/cDHCDGWBbh1TqHGTxyLQE9J5MnOcSPogvV7nohwcMbTrBYWBDmd\na3cwZQTOqY2+zKsmbQL1hzFx3B0c36NfMF0wDgYDVR0PAQH/BAQDAgGmMA8GA1Ud\nJQQIMAYGBFUdJQAwDwYDVR0TAQH/BAUwAwEB/zApBgNVHQ4EIgQgK/RSlPB9fjIn\nzkrI3zWG8KM+YR7JxCp2o2iTdyLxRQYwCgYIKoZIzj0EAwIDRwAwRAIgNFVs62GS\no2EAcpMAAJHLqRCvmkbB26PQ/HjpOskhntwCIGHF5a/2rVxbnYzoyiEqdoLkTQUq\nDQZ+LU2C8/Y1FlkG\n-----END CERTIFICATE-----\n"
            }
        },
        "peer1.org2.example.com": {
            "url": "grpcs://178.128.204.29:8051",
            "eventUrl": "grpcs://178.128.204.29:8053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org2.example.com"
            },
            "tlsCACerts": {
                "pem": "-----BEGIN CERTIFICATE-----\nMIICSDCCAe+gAwIBAgIQNiiy6JpOsf2z1SvhXd2ASDAKBggqhkjOPQQDAjB2MQsw\nCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxMNU2FuIEZy\nYW5jaXNjbzEZMBcGA1UEChMQb3JnMi5leGFtcGxlLmNvbTEfMB0GA1UEAxMWdGxz\nY2Eub3JnMi5leGFtcGxlLmNvbTAeFw0xOTA3MjMxNDM4MzBaFw0yOTA3MjAxNDM4\nMzBaMHYxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQH\nEw1TYW4gRnJhbmNpc2NvMRkwFwYDVQQKExBvcmcyLmV4YW1wbGUuY29tMR8wHQYD\nVQQDExZ0bHNjYS5vcmcyLmV4YW1wbGUuY29tMFkwEwYHKoZIzj0CAQYIKoZIzj0D\nAQcDQgAEKfOi/cDHCDGWBbh1TqHGTxyLQE9J5MnOcSPogvV7nohwcMbTrBYWBDmd\na3cwZQTOqY2+zKsmbQL1hzFx3B0c36NfMF0wDgYDVR0PAQH/BAQDAgGmMA8GA1Ud\nJQQIMAYGBFUdJQAwDwYDVR0TAQH/BAUwAwEB/zApBgNVHQ4EIgQgK/RSlPB9fjIn\nzkrI3zWG8KM+YR7JxCp2o2iTdyLxRQYwCgYIKoZIzj0EAwIDRwAwRAIgNFVs62GS\no2EAcpMAAJHLqRCvmkbB26PQ/HjpOskhntwCIGHF5a/2rVxbnYzoyiEqdoLkTQUq\nDQZ+LU2C8/Y1FlkG\n-----END CERTIFICATE-----\n"
            }
        }
    },
    "certificateAuthorities": {
        "ca.org1.example.com": {
            "url": "https://46.101.192.236:7054",
            "caName": "ca.org1.example.com",
            "httpOptions": {
                "verify": false
            }
        },
        "ca.org2.example.com": {
            "url": "https://178.128.204.29:7054",
            "caName": "ca.org2.example.com",
            "httpOptions": {
                "verify": false
            }
        }
    }
}
EOF

PRIVATE_KEY="${DIR}"/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/03ef643661613ed4ac8fbbf0a6c188df3b0f786d1e1b1c49d13bb48883a7db18_sk
CERT="${DIR}"/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem

if [ "${NOIMPORT}" != "true" ]; then
    CARDOUTPUT=/tmp/PeerAdmin@hlfv1.card
else
    CARDOUTPUT=PeerAdmin@hlfv1.card
fi

"${HL_COMPOSER_CLI}"  card create -p DevServer_connection.json -u PeerAdmin -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file $CARDOUTPUT

if [ "${NOIMPORT}" != "true" ]; then
    if "${HL_COMPOSER_CLI}"  card list -c PeerAdmin@hlfv1 > /dev/null; then
        "${HL_COMPOSER_CLI}"  card delete -c PeerAdmin@hlfv1
    fi

    "${HL_COMPOSER_CLI}"  card import --file /tmp/PeerAdmin@hlfv1.card 
    "${HL_COMPOSER_CLI}"  card list
    echo "Hyperledger Composer PeerAdmin card has been imported, host of fabric specified as '${HOST}'"
    rm /tmp/PeerAdmin@hlfv1.card
else
    echo "Hyperledger Composer PeerAdmin card has been created, host of fabric specified as '${HOST}'"
fi
