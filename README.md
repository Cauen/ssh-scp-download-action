# SSH and SCP Setup in GITHUB's Action

Setup ssh agent for both ssh and scp. Script can be run before and after scp operation has been completed.
This Action do the following:
1. Execute custom local scripts ```local_before``` (in Github's local context)
2. Execute custom ssh scripts ```ssh_before``` (in remote context)
3. Execute scp to copy files bidirectionally (local -> server) or (server -> local)
4. Execute custom ssh scripts ```local_after``` (in Github's local context)
5. Execute custom local scripts ```ssh_after``` (in remote context)

## USAGE

```yml
- name: Operations
  uses: alinz/ssh-scp-action@master
  env:
    HELLO: cool
    MESSAGE: hello world
  with:
    key: ${{ secrets.SSH_KEY }}
    host: example.com
    port: 22
    user: john
    # runs this on remove server
    local_before: |
      touch backup.tar

    ssh_before: |
      rm -rf sample1.dat sample2.dat
      echo creating backup file
      echo $MESSAGE
      ls -lath

    # then uploads these 2 files
    scp: |
      sample1.txt john@example.com:~/sample1.dat
      john@example.com:~/backup.tar backup.tar

    # then run these commands
    ssh_after: |
      echo $HELLO
      echo $MESSAGE
      ls -lath
```
