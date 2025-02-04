# Connect to Oracle Database using Docker exec with winpty
winpty docker exec -it oracle-free sqlplus sys/YourStrongPassword123@//localhost:1521/FREEPDB1 as sysdba
