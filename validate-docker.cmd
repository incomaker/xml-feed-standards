docker compose run -v %2:/xml/%1.xml xmllint --schema /xml/xsd/%1.xsd /xml/%1.xml --noout
