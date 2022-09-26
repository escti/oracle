@env_s

set serveroutput on size 999999

declare

what dba_jobs.what%TYPE;
interval dba_jobs.interval%TYPE;

CURSOR c IS
    select what, interval
    from dba_jobs where job = &&1;

BEGIN
    dbms_output.put_line('DECLARE');
    dbms_output.put_line('jobno number;');
    dbms_output.put_line('BEGIN');

    OPEN c;
    LOOP
        fetch c into what, interval;
        exit when c%NOTFOUND;

        dbms_output.put_line('dbms_job.submit(');
        dbms_output.put_line('job => jobno,');
        dbms_output.put('what => ''');
        dbms_output.put(replace(what, '''', ''''''));
        dbms_output.put_line(''',');
        dbms_output.put_line('next_date => sysdate,');
        dbms_output.put('interval => ''');
        dbms_output.put(replace(interval, '''', ''''''));
        dbms_output.put_line(''');');
        dbms_output.put_line('');
    END LOOP;

    CLOSE c;
    dbms_output.put_line('commit;');
    dbms_output.put_line('END;');
    dbms_output.put_line('/');
END;
/

undef 1

@env_l


/* 

-- Limite de 255 chars na linha? talvez script abaixo resolva...

create or replace procedure p ( p_str in varchar2 )
is
   l_str   long := p_str || chr(10);
   l_piece long;
   n       number;
begin
    loop
        exit when l_str is null;
        n := instr( l_str, chr(10) );
        l_piece := substr( l_str, 1, n-1 );
        l_str   := substr( l_str, n+1 );
           loop
              exit when l_piece is null;
              dbms_output.put_line( substr( l_piece, 1,
                                                   250 ) );
              l_piece := substr( l_piece, 251 );
        end loop;
   end loop;
end;
/ 

*/