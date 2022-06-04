set serveroutput on;
DECLARE
        CURSOR COL_PK IS
            SELECT UCC.TABLE_NAME , UCC.column_name 
            FROM USER_CONSTRAINTS UC, USER_CONS_COLUMNS UCC
            WHERE UC.CONSTRAINT_NAME=UCC. CONSTRAINT_NAME 
            AND UC.table_name IN (SELECT DISTINCT TABLE_NAME
                FROM USER_TAB_COLUMNS, USER_OBJECTS
                WHERE USER_TAB_COLUMNS.TABLE_NAME = USER_OBJECTS.OBJECT_NAME
                AND OBJECT_TYPE = 'TABLE') --to get all the tables in data base
            AND CONSTRAINT_TYPE='P' -- primary keys
            AND POSITION =1;-- to handle composite primary keys
            TRIG_NAME varchar2(100);
            SEQ_NAME varchar2(100);
            CHECKNUM number:=0;
            

BEGIN
        FOR PK_RECORD IN COL_PK LOOP
        TRIG_NAME:='ADD_SEQ_TRIG_'||PK_RECORD.TABLE_NAME;
        SEQ_NAME:=PK_RECORD.TABLE_NAME||'_SEQ';
       SELECT count(SEQUENCE_NAME) into CHECKNUM  FROM SEQ where SEQUENCE_NAME = SEQ_NAME  ;
       IF CHECKNUM > 0 THEN
         EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER '||TRIG_NAME||'
BEFORE INSERT
ON '||PK_RECORD.TABLE_NAME||'
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
BEGIN
  :new.'||PK_RECORD.column_name||' := '||SEQ_NAME||'.nextval;
END;'; 
                ELSE               
        EXECUTE IMMEDIATE 'CREATE SEQUENCE '||SEQ_NAME||' START WITH 1000 INCREMENT BY 1';
      EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER '||TRIG_NAME||'
BEFORE INSERT
ON '||PK_RECORD.TABLE_NAME||'
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
BEGIN
  :new.'||PK_RECORD.column_name||' := '||SEQ_NAME||'.nextval;
END;';
                END IF;      
                END LOOP;
END;

show errors;

