ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� d�Y �=�r۸����sfy*{N���aj0Lj�LFI��匧��(Y�.�n����P$ѢH/�����W��>������V� %S[�/Jf����4���h4@�P��
)F�4l25yضWo��=��� � ���h�c�1p�?a�,��&�Ɵ0l,�D� �ڿ\ۑ- �8��W����F�-[5�]��mS����@{�� �y��E��tGVuh��r�sI�ړ�(�34���fZ�Q~���iX��U	@l�0;�.��6I�z_��ug��*K�|�*3��.��� ��� t�dWsR��C�A�:����Az��%7,U��P�Qm��JN�<<7���d+�j�&0��� �)�l��-� D��>;�݅ú�U�"X��у����c�X��FR�5{Nj��*�2�L�a5���e���3#AJ����i[�������B��4����g�^M�|��E��h�H�����fp{��Kc̒�f��YE�3���w�D�+r�@5L������9e��{5C�	We��B۩����u0s�eR�#�X���sFݔ{5)q�\I�ub��1*�������Zy�A~��f���_:t��%Z�W"���tYi�I�w��R�Z���5a?��?b�ȃ���x\�i��0Z�Y����,��d|�����w�l5���-Pa�s�6��7�?�qx��h����?�����[<�.�P�HC�;�m����P��OS���C�?&���Y�T+��ẇ+�����s�D�"g�!��1�oZ~y0G����������6�����s�ߔ�.�·�mC�6�������"��?�rHDc���G7��Z o����Yf [,�wa&̄/uڷ5Z�B�l� ����<�p�z�8?@˰ж�5��nd�0]o�|LK���ѱ\H�d��֔S���T�6鑈��C��хC��k^��f(]�#�]����+���.�x����	u�mUԱ���ji���;Y��Z3$[JG�\��j&���`a��"8I=��@z��Հk�k4����$5ԾT�,6̏�H^z?'1�3*�J��7抺�(�/n�����&_�k.��8_�sL����Ρ5A���u@����l偖��8p:����em��ч(��uUo_��q!�1�/��u��=�$,L�~}I�-�[��,� ��4>��U�HA�c � ���Q���� |��"�a#��i�e�@�$5S-5�M6.[�nl��;9j~�f� �P�{�G13@#8j�+�d �b<b
��k�}�&�m1�^��V1���
2hƝ�d>�w`��y�8G"3oU�<��}�/i�V����6$_���>������ю6G������\�!�0�M�:4PuX��ч�ml�A����t�A,�3�)什��0'�����?���1�qc�Kʯh�U���W���qz����&���3z���D�^а��}��q��1�74�g��P?ڲB5n��/�������au�2�������l�#��s�@m,�������n����NJ_�_<���l����iS�c����v�����4ײpHk �ǰ�T:W޻�:�����Y%U�V���t�1��|ˮ���� _mc����DVnFL�s���T��J�WW�f�o�N  ��nC�Gd��n7�E� ��&��:�lxs��F��~>����;�Yz+U�\=��
R�V���	�y��xaC4YM��L&Jﱂ�lZpo���P�ë�$*�x�<������s��xKB��I�Ed��@w{h������,,.��dAG�t�V�d���舯�|g]��f�BOr��,bs���v���ȸ��+��l�������a��O���� .��(�L�qa��xx������{��=��hB4�B�[����1��ʾ�:��9�?e/ݿ���?�L�����?��0��=�`����?`�1��o�����=,x��ǅ)����g-0��W»pCG{p�v �,�����;��^O֛v��;�����	�����t\�|�#u�~�ľ)�cm� �Bt5'�3�Px�Bd2�n���6W)�	�ԝ SdԴj� E�����_b1u�B����G������y50:�FY=�Z����\c��_�����"?�-w}�!�������������t���\�=r��?t�hG�$V�I � ��Fz��t�ث/<�;{�;��!&̆�Q)��҅n������gy���g��.:%�\|��xT�Ep�TcݸV���,���5WncA�?�3�!�l����O����V>4���]����ς��?�3�����_�뿷��;WD�ǁ@�� ��QI��ȶ !sE(Ev�O?��?�J�5
94G�'w���N�� y�;�Y�ڙ��C3Y���k�\r��P��c�m܂�N]!���~� ]�zw>��cYu��wb,ʌ�z���`&�2)�Bc:
2�-c>1XG�ABݟ���n:BF��
���5V��L��˶���c��0���׀m���WHV_���̹���k<j���ƚ���m��0�C���ꅋ�BR*W���YJ<�RQL��>�	 �7���qA�kj;��ML�p
L��=��H���١$���t�,U*b�ZJKU)U%���ԓ�a)W�z��p�/[��}9
��O�H����ٳ�T��{i)Y��4�K��I><ȝIh�1a{�œ2��v��~EJ�ʹ���$ހP.��7�wu6ե),�ϲT�+N�^�|*��T�;��	V3��!l��&^�*@7��;��g�ohn��7E��?��> ����kX�B�?���Ll��o-�������y��WAr��k�`��� �j�P����k 6_o3;G���A���]c�%�4>t���O���o,�[1��b���<^N��{E-�A�����D�7�����}.�[��aXnj��Q����u��������!?<t|E�좰�W�[�@Gԉ^ƫ��gK���ly�|_~C��� �����+�p{����9q������p���F��_�b���|�_|���qs�`^���P�����W*�_��Z+��t���2w��e��>�B,��Y�/'l���g��_l�[�zj��Ƙm8�<ji�p�K�0ZV��s(x��sx�?�����f�_�W����e�<�\2x�0���ڀ<� �� =|�!����s4F@�X�����J��@/�Y?<3�-��ރ)��8�����_s�_]�~ee:�L���a��@���#*So��}6enŸȜ7R�B)o��z�Њ�O����M����[<t�D߄[��`���������6�
��:`���Vb�z
;��X�-���� D7�������:�>|�����?�����?O�??��F�y.��RX��r��╝D"�j$8��ːg!��D�Wd>!$l#�#p�A����������x+��oԟD��Td� Cd��֟�?���֓o�ST��m�rT����[�Bm����o������j��|5Q�-��v���������ѿ��5��㱥:�����e��8�!�a"��'��װ��z�o���X�+�����2��������[������^�o��Zࣿ�
<��#�j�M�6�iЖAG�a&?�r�T�{��F�PG���@��t*�����6������"��e���x��b��N��i�$`K�;J��0�
����(�-�݉ˉ���#AM���>�
D���� ܝ����AJ*Ws�\J�J$��^��R��TJTRmq�K��\Y,�%�^|5lF�١�6�RW;��'��4wy�Hw�\JyT��͊lMJv
�z�p!]��d�XGUUS�b���z��W>�.2�b��S��:�S�����˸'�vy��\d��[èJ����RrO�v:��I��"�78�b?-�N�*q��{=ߛ�9��(�BU�s\��cJ�w���I3J{��'�#{�::I׏����M�v)Uh�p�R�������Ӿ�̓�t\Hy=�(��5.����ɱp.�-�7.�V!�q08>:.;� ���A�ٌ�d/�|��oT��h$��lr�k�R�b[ʦR�/291�uw.�Gl�{Q��F�/�UO��'�F�p\��I����q=��k��@<��͊�
��i���w��x�.4˱S^fۃ��j5�/�<�Dm3=�������vZ,��/�bkG�E���q����Q��:sɞu*��d.�x�[�|wp����!	�ɥ�Ť2��ʽ������`Jd�bA��rG)�>8���SR��F��;�eB8ND:��x:'��~\��T3�ε+�A����FƐLY�
��[y����eF��D��,����{���TL����*	G~�z;�����d���˰��Pc[�a�{�D����e�mx���p�����;�_t��}������?:��'ʲ����Z `'�su�8�鄤>�
��>Z�����d��؆::j3Ln��'5�P���S�$֙
��ǚ��2i�\��t�� �+%�e����jŲY�u/3r*����R���O)�ޭ���P�hP������Nu���a��9Y#�;̧����d�cRO���7۱O=�|�??��������񩻾�'�����Y����ߵ@p��%�Tp��t��d�w�ģ�+$-)飶(��%e�5��yS�8n���oڦ|؋>��R�4S�JPq˧o�z����h�M�� ߽tt����6o��&�o��jNN�����>M٧���A���c������%�X ��8?}�G��7�_k�g e�C�DO��/�Q�@�٠	_4��3�y�~�{�+�<_nK��.=�fB=����T��6B [����)����d]�$i�d]n�{k��%r��~`�����[9��o����܃�� H=Y�wA ���?t۸F�bB��bB�?;�Q���U��?5��э!�o؎N�睇g�Q������#J���2/���s���}�����lq��!/]�_���Р7�vP$"A�8�����j�"|��O��?{W�ʑדl�NH"�}yaX�f�M������h��nw�n�۟���F��v��m���v�^=)\a�ja'.H8!� q@BB�!$���.PU�����f�<8�Q�����Wտ��Qտ���8o��6��`)*P|�R>w�������F;���	X�Q"��5���X�-P٦��I-� ���eW�>��8�|\WΧ�^<!�>�~�7
�|N�`d����N?��B�#gl<�`��'�.�A9�,�y�Bc_��y&���7���ge�>fA�'}����pMbW~������ϟ�_�H~�|�J&����� ˇ��}
؛C\�f�5�@u	'�Bn������6S����퀵����a�4m�t�� �`�%�_�)�����N�!�׹�_>:Y&s5��o���Z%	L.I_ޟq�4����{�{z݀PH5��DqM	�Z�O"l"5F.��!x�ׁ��Z�� ��������� Ó5�#�)���1��o��KTK�@TC�	��8ӓϝ��@|��HV��c|D����L_����a��4Y�i�r�#Uy���5,P�}ۈ�$:�	]*>�ZS$hT��ԄZm��,`�����sM�s�9*��DQo�u�.K�.Zt�TP�]T����p廆�k&b{O#G\�q��m�΍��v#��	?a�2кU�eNϟï<���!�;L�O��&�[����2�F(�$�v�3�<���2ְS4�0��j����A�L�o��U���恤_w"���*�$6���(���O��C����}����������O��7���?�˟�Ħ�z����!�C��m��M�X������ﾵ�+�6ڑ�Ϥ��Ͼ��z����x/.+�X2�ǥ^,��D��x/&SI9@RR`o'񌜄JO��i��}������_��,���G?3v������w>���V��~$���?@��B֚��� ����nC?{���+��������WB�� �OV��-�F�c��`Lz��[�*�t��o��LAI�gM�a�#FU����J�Vc�3f� V�mV�� �:�u2���v`��a����vBZ�ّyyIG���\8�%���i'��BA�g�t���EZ?��`sN�x����|�f�P������gS"lB\���}iXw��P�9qs��;/���eK���XBݶ�*�a	n^>k7�	o�VMjЮ�6=����`�r�.�M���l�=6���U��Mv���bѹJ�֪��_�r�Y�:�gJ��LB�D�{B.b����H����^�:�AcE(�n�	&�~�6kcb�!n�4B�-�1F������<���ɩ���ME���N1a��xrV�O�E�=�����&L��C�u�W���YXo�YLp�`�LZO,��R39�W��)w���4U�|�D�6I0k5�V�Ώ��l,%���L���"rD�'���Fx�<A]�~�Zm����+���+���+���+���+�+�++쒸+꒸+�؆��B1�w�7:z�M$�?�VQ,r;����f'"U�0gK*Y.w"z=;Z\t;�����s�%��K����%
���]�|��\O�.��{�y'"n�~����{�jr:����46g���U�YZ���ݳ�>��F�U�dI��Q�Hk�DDk��x�	❺�˙�Ʉ�c� �D-y��!<��"�'�1��~���#��4��lyR��z�P��Ҧ�)�Oڱ~�ܾ�����,��PĔ�e�
5�'Ԅ]1�&k�F햚���ULS�A��OJ)z���� �p��ѱ�lv��I�Jȑz�^/;���C�
-�u�f�EV�������C�B;���o켶�6�����n���{�n���8��0�l�ˢy>�V]�.B�����Fh���(�҅�W6a��e����)ځuy3�F�5��e���-N
�ƣ�O�I�s������ �;B?x�?G�v�)+-�)�����VzVM��2�E�K�O�r�{���e��K7<���n�}��9����Ryl���D�t���"n5-ᘮ�ͩ�鲭M|"0M�W��F(
QZ"-2j�u<�r���Y�iV�Pc�T���&���>;�*���IV�ّ�R��0�K�¾6�T;�Q����CI��m�;q�L�Z˓a��j��xlPi�8�ce���c�ڞE�awڌ���w����x�idLa!�ǂ̪5��2@�C��êF7{����~*e��q-�|��s�ߢ��`Ik�R-h��h��N�Šz��(��������⃓
� �HB
���iw	���T������p�)����wf�R�?+��]^��ɂO�W�{�v��dQ�,��r�]�|sX���.ULuگ//���K��M��=�_��sK����a���G��*&~\L`ۋ��(��EY7`櫓~�}|ƕ<u'n�8�?��n�`��H-}Z��̅�)�[�ɖ��rUk��Z�F�yS���;lm4j(�Rx��jͱ�Z�l�`�%����a'C���y��ң��=�;e:�h���gnq�
-ж(sN��h�>r����lޠ��p.$�V��j�0��zo��j�Ϗ��N�D�i���j6_.��dX��}Z ӣ�I���;�J���My��Y�`b=�������Fe�x:_��ق�s)��-l�kd�Ԡ�"Q1[K����b⿺V'�"r$��#ʳam<:�RS��0%�b�Ė�W�H;O��d���G�������3!n��9b_�L ��yΤ��yϡ�9���Q�j���Qv�o&�F�#��#�5�2.���I�Z���Sk�j�[�c
�t��.��U��I��4�����LOg�^�'ȣ�֡�G��PR�R[<��3����
U7GvM-�Zb�L�λ���P7,��P�h��5��Ƌ��4�R	��EwD��$3�ҳ!ף	�2�p��h�0`�Ƽ���dLrnՖ�f��B�t��L����*e����*�}�ƀ������;��-�ɋ~o�)��7�����0���E��л�7�7��G����7V�+�5ќg���W�_@��Ȝ��b����E�i���?��hhK%�0�����_~I}�嗤߆���m����h㠈 �'�7��i>#�c�+�c�k�s`�e�|9}B�_ f_�����?D�=�L��O�_ļY`7C��N�hv�~���y�}�shY�(����Dh��Ѕ?ߦ�C�.���4�ܠ'|���9�}�������Ț���?׼��$c��G�_��{����"W��K���I�I��S��z=�;��t�N�31CRH�/�}H����$�E�ɘ0�1���b�Ce�!�Ѯ*�g�ؗ�.���C�p�MX�\�w^���Ms�W	������OXUa�T�����$��g���i�5�z��/[/���D�T��t���Jn)�' �E4�����}�	:\��?�� ��@H���@'݃Q��A"L���D���P�g�����AE�c�o���� >��F$ɩ�]Fkbw�	I�i���.�#�,�(�r�iX��#/ijy6 ������j[e�&$��������t�O�����pe;��7؆ ?���O�{�bP�Lэ1."����Q��x�.tS护���ը�Y�$
��?Ym�a[�ir���6�=~��Y;>3��!��i(l�5_�p ��q�B0zE��R�)�)>z�=IneP`X�h��6�!Y7 G�Ibթ*���;�}�uG�w�5�+�R�D��\��͛7�;&u��m;ذ���:o�æ�#~��DP�W����a���g~������ȵ��| D��M��iԵ��E��xy!���.��Ā7/1�X|��C�[k��!nE��y��T��Dgߟ��"_)��]�k\�9ވ�o ��fW�I�L�d3&�ٺ���u�dM#[W��x'R����]G�&�h���qzDHti)�v_`�����Mw6c��x-:�aL�� �����E8% �l����Y�W]��A�k%N}��<�сɨ�6��PRz���F.�ʋ�\ɨ�����8kdM�� _a��R��<p��ck�I�����\N��
�l��d����c��.7�	�FKP�S��Q��Bvd�_,WBT�{�v��A�l�2р�%�������ĹE��݂3iR`�����ml٨�����G�^2�&�Xo:Nǌ{�8���1T�4~kL֪�d[��o�J 	*J�9Bzr(���`�u���Ӑ�� p�����GٛF��"<4�W������xem�i*�B��P��H&����ynh�U�@��j!K�MٝPZ�
��b��D[ܘa�X�1�vc=R~��q��ثq �8_�;��O��﫳�m�a�����^��x'εe\��?���V��ţ�����}%��X!>�~Jhh]'*�r�c+�Ek�7�+Qf<���9�����,}���xV�nx+?wPn�����\}+ӐŖ�_��:��������N�=+�tĵ_��ʠK$�( R"��* Sb�^2��v�%�z Q)��De�'�2I��M�Ss�X2������+�=+8ͽ���}�i��t�>N�K>�)���Ґ�bK��sx�ŋ��2@J&�$I�x:���LE�x72 �d2�QR�t2�Ā$�;$@J2�Q�)�I�@��O%��C�wl�O�O�4f0p*q�_x���Û�����Sg�ܶQ	�M���Bx��n�}�R���Y��u�+su�tZ��K�1Wz&+�T���o�\�f�:�h<���*r)5���7N,T�gx�������_�e�Fe�Ш����u�讫U�co��� ���9٩��g���
�ZY��nXլ�T�bg�k�wD�MG�Fg�ed;c��8�ĵF��w�EQ�-	�b����o_"�>�XN�|�_������94��|9Z���H�ϳ�/g+��Q
�c��u�c�+��
_�MG��0������'ӑ^���s��Oᐼr)H��%�īK�uc+�#��Pi��J9��O˜تԏغg�������;Κ�E"��p��b�Ҡ
�ڲ���ü�9�/K�4C7�gYt*�\A��4���e�ʚ�֚��~�}��A�p���O @!Ġ�S��$��_��;�ډ{=��!�mi�ս�Wk��wz����4L��D��>�_�[�줗W����]�&�3��i��g��~�.#Ǯs�~�T�����{���+��kz�|�f���?[�7~����>�\���ۣx/��߯g�w�m_��񖸰���q�~|������;K~��ޅw�HS�u;��g<�w�K�E|I�{�g�>||������\��W��I�����	�_P��������W��7��$M2��(������߲��Ӱ�(���7G��������g�4��26� (�������H�����������?������}>-P��O�)�fn��ߑ �g�~�g~��Lя�/��ݙ��	P�8��s8�I�	bD�����(1\G~(	"ƼH�#&d8�	V�2�)���ӏ�;?7p�����0�	����d����|TL��d����]mC�z�Ѧ\3��2��Ŵ�i�>����4�3����u� ]#�6�sK���f6��sl7��;�RÑߡ2�?�Lml��p�Mz��x^S{)���?Y��uy��x�矵;<p��!�_>��
C�����@��o�����Q ���;��P��
�����������M���(��/e�E_�O������n�?��� ��v�^
� K�������?���?��x���G�P%����g��,���?�?H s:aN'����K8�,�u���?� �����?��Â�����D����?� ��s�m�'EA��/���%��_�?�z���[��u�s��͕���S!�������?���O�=�����f������I���3ϫcY5B?����퓘�4�M��Ғqjԏ�"jn��f9�=.˻��:mP�������8�+�����J���*k�P�|W;.~#7�_��|j�$~���g��I���]W����չ|�b��mV��p9����}��q;-��i�}=13� �s�T�4]~[J֬�F�6<5��D5��y�r���;n֑�KQޯ��:d�m�X�]��G��K��ߖ4�B���a�@�]D!P ����������Kj`����`�7���?���?���4�?�@���������[�a��������� V��M� p�����8�X��=������{���|��#�n4���ͻ��_|�_I���C\���^�w4����K���v�]%}�#���QG���&��Mga8�s�K6�:oxk)_�R�6�HrJ=I�������m�m�&C����e��5�'���cٔ�k\�?���,獇�~��vn����s���;�_ر���`'t�DF��i}���X[���xf��b1�U�d�t���>��2�(=�b�'�JFN,�Ȑԣ�I���[XC�?P������(�(������4[mc� ���[����̳{�����H��G���GE!�S'r+r$'IAL�l B�a����!�!Ʉ|�1�1	3~8��=�����w�����ט&ʪ]��-�HW��ߞ��z!K%f�צs�I�����o�b�,�lg����y��p��zG��*17��lph��p�/���[AK�D�h��l��c���u9�j�[v�������a����P�����ԷP��C�W����)�����s���8�?���w�;�ֻ��^�/���8���xy-������!���j���M�o�=5i�'�oS�.��z�gN�11ʝI���%g	�IR�گ4�甎�\��v���_�|������d�-w�����c��!�[0��C��p�7^�?8�A�Wq��/����/�����b�?�� �On��Y��C����w:뿄����Nج��~�[��A��~���G�B��Or���_YvR⬶��@\_|� �[={w�Y����<��w�*q�� �ޏVl�m��R3[1��jI�ș��R��4�Ѭ,���u��)�K���5��@֣��Yu?ж�!���z��S�ʖ�i�9�x�}�O������}�� ۭ(���ね���,>	y���-ڗk�$i�Vu�S�@�Nٶ+���hZ��J-�m���<t ���TJje�̽���_jZ%���n'���۪��dc�[W�b���B�46j�d2iFsI���f�c��Ք'�4�ʱ�ju�*���l�2kl?ۘ}1O�E���Y��،d�p�{G����P����Ї
|�b�_:�#o�?8������i�����#�O?l������H��Q ���������X�'
���GI~�s~$+�B�G�!�K���<+�)�b��At��34�R�
1��~����;��� �?H�;��V������c�K�$�{=Y=hVΎ�M�=�ɮl.~��u:Z0X'z��8'vj��F�#w���/�b�`��z�ȷ�I�c���{<)��\�����Lץ�f�J�W�n[$��@��k���O�w��@�	>��/EK���b�ߐ��i��(���7���C4��G�	x���������o������_���_8����W��i�(�����7T��[�ֲg��QY�Wa��gs���;<R����S��N[c�=�ߗ׈��~_�����~�y��w2����O��x����Ŧ����5{��^��a�?�2^�N��Ԗ�Y�'�;�h�7�Fŏ�Ʉ3O�ֹ&Z�`�f�����Iޘv�JӔ�*q9����/k[K�W�s+�����P$b�i���b�^8qh��֖T+�9��\����mUv"����ʦ�'T=��å�I��Ry��J�fp���yOګQ91�k�U?F��J_������s�AϬ�}rrTYI�G�ۑ�.�F��Y���߂�F��|w\����8��y���� ��(�8��w�y��� 꿡�꿡���A�}����)� ����[����p�_����G��,��;��4�?
��/����/��{�����������/-�{����%�g �G��&�����GT��������_<����P0��9D� ��/���;���� �s���_8�sw�@����`����W��@� ����K8�,�u����D�@�AgH����s�?,����� �G���B
 ��=��� ��������A�����@@��������/�s��"����������?���?�������t�@�Q���s�?,�������a�;`��P��8��P�_����������,�uG�Q��P �7��i���� ��?��Á��g��@�����b0 c�Fd(�)�D)�l �K31Cq��dx�ЧD��J�}�gYN�7��;�����������1z����)�������T�����vB�F�l*�դ,MfOx-�G:� ����|?�hqx�4�%�wdK���v���ku֦;;U|U(�z�B��JA�lo��w�*�s{5�:I�q�V�n��i?�˚�;6�Z���b�W��5���RE_p̀����š��?�éo��a����8`��P�S0������}1>!p��������!cr�R���Ҳ�&�Rs��i;:u��Y�ڇ�(�����u�Y�윹u*��R��n�F4��4{4���[�F�C�ؔ��N	���i<\��1�v����8'����6�i{�s������w��"���n��k�' ��/��*���_���_���Wl�4`�B���{�����_���W������Ǩ}u�/���N���ا�\�U�߭���E�i��xUj���@�5̺�ng�nX.i����Y�6\	Y�X"҂Mb��(�8�=Um&}��l�v�Ɣ�ʧS&mFLjY�I3����������UN�j�~�x�/ץS/���[QrS9�[%�+��_'Oe�x�Y�E�r��$�ت�{���)��c�HQ$�A�qZ�ź���Y �M�V��p܍���#M�A�L�����G,̓7rv;�Tmμ�<Q�� b����W%�yV�$�^%�ڀ+Ż3+��kN����{{����mo�o�?��4)P<�R���	>b���~����S��h�C�G�w�?��	>���:�A��@�����,I���(���$u{���� ���O������!<�������
������*Gǯ���_���`"�LJR���g̛�<�~��GE��'��~~X�ʫ7�����J��[�~�����#�:��)�G|��ٹ�<�����ԥo*�S�sI]^2���[ے~W�*I��i5��YWSQ�KA�S_2��꺔�s��m�1�/ti�W��ZWSyԧŽg;FB�RwM�sYr�V�S�&e�s�]��Uf~w�	!���%惮�z8����k��>���˚+�P��,kr�)�G\��=�d�ʦz�'"-�'��ns��0%��,O�S�t��I}_��\iӇP�3�5k�gY�Īɚ���7'��P	[��ణ��ח��<H���_��bj�#Q&n�Wr�0$w�"�M�?d������Ώ]������-����=�������/"��B��O1~ �D��}iĄ�~��CiD�4I�Q(��4�!�C.$�@����:�?
8�����g��H�;��5>�5/��I0HB�����7�t���QD�=%~����+ߪ�-r�V����������}��w��C��ぃ���V�A�	<����(����[�ǁ�C�����%������ouӉ�V�GK:>�7�?��6��ǂ:=箹�K��x[�o��܏xO���#^�������k=����~���~63ɜ����J��ۻ�fE�-��_a׫x�:|ydЎ�� �y��� dRA���{���y3�*�������^@�����9{���i�V�u�g��>R�{���\�\��u1Y�7ʎ��N��i�w5C})������<sE�rd_���~ȷ��]���;�~�&�]�cQ�aǦT�'e��Ti�ce�x����֞��|}f���q?֙�uo&i�����Fƌ!׳n�X����]�ci&gmkݍ������6�6�1ʋ�ך�+�Du����If���?�wE�q/��3A�?��:�t��c�J錟N'�(�0LM�T\��U,٣'�`Y�)B%p*قWk�{Cd�����ʳ�迷�����K��)�q썐cM��f�H� ��]]`�G�������˖T� �*[`��k���j������_(��K�ޭ��@�e�,�5���	��������C������� +�����&�gp��3������A���c���<v��}�%T[���ۃ[����?�ۜ|�h}��xf'�u�nǾ�( &�8rV	�v}~ꬄS��>u6�d�|�V��-����u�
�֩����t劝�\^[�km�������B^�<���y��Bg*����nz�1��Ѿ3Y���74:-���:��oL��N"ܠeD�x�.j8E����c��ï��������i�/�m��e�G��#�fٸy��Yq|?���5u�mjk�{�l����ژ�23�wM��ۺ��x'O,^R�7V]�䄃�l�mu��g՞!-&�Ҙ�G�/(C� \ŔcW�-�B�8�X���#�*5$s�7Y`XS�Nq$k6�V0#F|��V��l��Q���[��2A���B�_T@�������?�,�A��B������ߙ �?!��?!���A��U��\C ���������0��2�0�+
����%�a�?����������;迷��/��}���C�����I��lP�gn����3#d��7i��#���������_��y�:.���������������2B������?w�'����g���?�B䄬����?$[ �#���?������3��� O�E!��������ʍ��d�"�?T��B��7�	���C& �� �����Y�?����?��+���n(��/DN(D�����?��g� �� ��|����?��O&�S�����9���������e�b�?���B����� ���!��qQ���0����k�F����??@������_�o�X�!#��u��qӪ̒R�I0�R3k�Aꦺ4+U�0����$���VS�=i`5���M����ã�_�o��������@�$aQ�)̯��`-�msm�;��a��%K<��:���j:6��[4}v�ܯ`u�4��H vh���M���u���ĊX���6���=��!��2��2�WCta��.�O�H�7�
�Pz�*�pCi�i�g�BD�'-����w>kUy�$7�������1޻����`(B����!��?���oP����P������'�_>�)	�n��E����=�?N�ڄ�=b��8��f9��F0�;���wyf���5^㿦0Yw���h�jz�`;�u��ȥpt�$�N�JU<��L�Q��]�/���)����J�z�XK����P=�<�_�b����	y�����?b���P��/���P��_P��_0��/��Ѐ9����o�_����������_�cE���V��#	ܐ�~8�'ο���x�uN��kk�3�->lC^�����r��`ڧ0���io7�۩�M�]͛��*G��O�;&��%r.o�Z"ɶ���51u@��u�WԾ��W��1�QBs�չ]�%/���~�"����g-7���
8K��^.S���7���>k�ѥ�@�� �7���:�Wj�גy���D�#�8{>w�]��x_�����*խ�qt����[Gny�W#�Gd�z*�a��}1}gخ�I�;!5i�鸫K��mUv���5�kA���?具��_�d��"���K��M�G�I�?!���Q�g��1��Y 3�y���������7�؍��
�?���iX��� ��ϝ��;�?0��	r��W������������������H�.��#+��s��	����������qQ������	r��d������_!�����X�1"��o�1���_��8�����9�����z������^��M��:ʶ�C���K�GL=�~��ȷ����k?�C�J�GZ��|E��͍����k��ux����~ŉ��>w����yZ)���!��H���CsYs�N��dm�(;.�[8M[�Y��=��8:.H6�����ˑ}e���"�Z�{-�E�����pv�E-��R���&R�펕��>�[{�����m"��~Ygf�ֽ���#{�3�\Ϻ<��0JC����:�L��ֺ�uGm�3lrc��5�W
��r{3D������0(�����ܐ��{�x�m�����_!���sC����%�d�B��w��0������_���_���$�������E��n�������
����
��w����F!����_����4�������n�;bG�'U'J��g�j�_����K�ux�s���Fw'�k���  /|��X;���5U�nV庪�4�U����۲:��Jc*C#D9:l�x���ÁݮLl���c�B��?�W5kM�߯@�"��R��E T0��x��ִ�)�5�g�����ji�)�r�LB�l�a��uXM��2G�5�#�J#2p�b��[�����tY3gx�k��Ç�ߌB�?���/���	r�ϻ%�?��+�W�;����,P�'k$���4iUWkU�XV0�0)L�I�� �j͠p��T3MJ74�6jU�X����~�?2���������l�=��1f�^Uk�>sF&v�_M�p�ts-�V���y*��3m�����V�?���Zo6���������v��B��Q^��=%r��p^N�"�	��t �zت�`�ϯE��������"Py7����?�����?�!w�Y0	�n��D����=�?��L함�$�C�RGפ:]qo�iEb���Q���������?Q��hG��_'���GnP>�[�)���i(L�V�0Z���S�;�+��W��+i:�1� �m��r�MhΎI@���(F���E�����G������9��_P����꿠��`��_��?��A�EU@��/�i��,���kٺOO�C�D�2��F��ݤt����K����V�\x]P^[�^�t�S�~�w���q��6{U�׶hLj<�O5d�V�բ�D'�΂��V�J�66ϔ�j�~�h��(wv]n����S���:�Sٸ��y����x�q�q���1�Pb�c������Ƚ����Qk���UɋƚRd^C�X��V�p�Ҕ��sX�(�78>���<J~4��L������ˍ�V�"�q G��	ku;PFǗt��Hg��V�B����Z�:���Ʋ�=�Z�S�h굨e�|z�B��fca���99�+�������mm���Y>Eǯ볿����O�� �
��.ݹex����Qz�ҹ���ig�tR݄Q��6�J"�d�=/J�{���Ͻi��ӽ��l�����^���|L脥w�}��#n��ץ���w�e������3��y��z*>0���8:�>�~٘�bK��r�t�������k���)���=O���>��8E��tZ�������j��jjh#�?J�щJ[�d:A�� ��.���E%u�I�W���Q�qH�#�V�l����H�\:��G������/?�����,��%;<�5�׿r��~�x��������T��?K~�L^%gE���kr��~��#�2!��y�l(�3oB?=���nJ�m�}�{�~��2��XM������7������ty$JѶ���$�9��&�ߚ��K���W��<ǳJ��������{��)�G�`�~$���x��o� �$o�jF�?�����Ͽ�;�7$����{�������z���='�`�%�0�iX��@�y����~9Żm�NL�_Fa	�~N�is�F�����C��~��ӋU���{������x��.�%?1�;��a�=��ݎ(K���E�E�0%�����Rz�O_�0��r�i���KW�����Ч���g    P,�?$*�: � 