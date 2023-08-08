CREATE OR REPLACE PROCEDURE TXSTORE.HANDLE_PART(
    IN V_PART VARCHAR(1000),
    IN V_NAME VARCHAR(100),
    OUT V_RESULT VARCHAR(8000))
    LANGUAGE SQL
BEGIN
    DECLARE V_COUNTER INT DEFAULT 0;
    DECLARE V_POS INT DEFAULT 1;
    DECLARE V_ITEM_VALUE VARCHAR(100);
    DECLARE V_ITEMS_RESULT VARCHAR(8000) DEFAULT '';

    WHILE V_POS > 0 DO
            SET V_POS = LOCATE(' ', V_PART);
            SET V_ITEM_VALUE = TRIM(BOTH '0' FROM SUBSTR(V_PART, 1, COALESCE(NULLIF(V_POS, 0), LENGTH(V_PART))));
            SET V_PART = SUBSTR(V_PART, V_POS + 1);
            SET V_ITEMS_RESULT = V_ITEMS_RESULT || '{"itemValue":"' || V_ITEM_VALUE || '","itemIndex":"' || V_COUNTER || '"},';
            SET V_COUNTER = V_COUNTER + 1;
        END WHILE;
    SET V_ITEMS_RESULT = SUBSTR(V_ITEMS_RESULT, 1, LENGTH(V_ITEMS_RESULT) - 1); -- Remove trailing comma
    SET V_RESULT = '{"quickpickCount":' || V_COUNTER || ',"selectionTypeName":"' || V_NAME || '","drawGameBoardItems":[' || V_ITEMS_RESULT || ']}';
END
@