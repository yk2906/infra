- ansible コマンドメモ
```
ansible-playbook -i inventory -l ip -u ubuntu test.yaml -D --private-key=~/.ssh/private-key-name
```