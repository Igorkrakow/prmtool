CREATE OR REPLACE PROCEDURE TXSTORE.RemoveXmlns(INOUT xmlData XML)
        LANGUAGE SQL
    BEGIN
        DECLARE v_xmlStr VARCHAR(20000);
        DECLARE startPos INT;
        DECLARE endPos INT;
        DECLARE xmlnsStr VARCHAR(256);

        SET v_xmlStr = XMLSERIALIZE(xmlData AS VARCHAR(20000));
        SET startPos = LOCATE(' xmlns', v_xmlStr);

        WHILE startPos > 0 DO
                SET endPos = LOCATE('"', v_xmlStr, LOCATE('"', v_xmlStr, startPos + 7) + 1) + 1;
                SET xmlnsStr = SUBSTR(v_xmlStr, startPos, endPos - startPos);
                SET v_xmlStr = REPLACE(v_xmlStr, xmlnsStr, '');
                SET startPos = LOCATE(' xmlns', v_xmlStr);
        END WHILE;
        SET v_xmlStr=REPLACE(v_xmlStr,'ns3:','');
        SET v_xmlStr=REPLACE(v_xmlStr,'ns2:','');
        SET xmlData = XMLPARSE(DOCUMENT v_xmlStr);
    END
    @