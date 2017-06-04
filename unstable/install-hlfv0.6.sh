(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -ev

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# Pull the latest Docker images from Docker Hub.
docker-compose pull
docker pull hyperledger/fabric-baseimage:x86_64-0.1.0
docker tag hyperledger/fabric-baseimage:x86_64-0.1.0 hyperledger/fabric-baseimage:latest

# Kill and remove any running Docker containers.
docker-compose -p composer kill
docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
docker ps -aq | xargs docker rm -f

# Start all Docker containers.
docker-compose -p composer up -d

# Wait for the Docker containers to start and initialize.
sleep 10

# Open the playground in a web browser.
case "$(uname)" in 
"Darwin")   open http://localhost:8080
            ;;
"Linux")    if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                 xdg-open http://localhost:8080
	        elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
                       #elif other types bla bla
	        else   
		            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
            ;;
*)          echo "Playground not launched - this OS is currently not supported "
            ;;
esac

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� �"4Y �[o�0�yx�� �21�BJ��EI`�
��ɹ�l�w��2HHXW��4�?�8>�o�>��ؾ�E�n�n����s�ʻ)�N���Uf[�$I�"J�؆M��t*Pl�N��_J�8�L@%"f������)	"!�=T�Ջ�[(�/ p���>�X� v�5��f � {���`�����ug�i�a���A	F����'Q�2 uP�����Ԇ��s�Ece|�h���/��e���I�FU݈�(�ѲuMϖ3���$���9@��i����r6��ļ��lͼMb6�7;�O5e9Sm�4E�{sc:P�o�z.�4��t41����dA�$�;=΍�6�A�t8M�KUY(jw��̇%��4x%����R���v3g9<�7ުW�?�+��62��P&Ѧ�J��0Z6w��]M1�����յoq�2R���m� rՖ��p���Bh�ʀ���K&z���wbef+K�|&��{����_�z���5�c�.-�kxe���m0��͖p:�Mu���tr;������� U��<dE����;(��9�l��Z�P�g��ڏ��S��B���}�	�����^Q�~�s�v��#��a��g�q��E�M��M',N�������k*�nM�����/N�j)?�]s�*jQB�q�J�RY���}1qd�4����r���9�{���=�7%ܴ]�&�kL�����t��zq|�������p8���p8���p8����M~�aV (  