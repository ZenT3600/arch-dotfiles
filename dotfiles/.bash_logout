#
# ~/.bash_logout
#

if [[ -n $SSH_CONNECTION ]]; then
        IP=$(echo $SSH_CONNECTION | awk '{print $1}')
        #IP=$(who | awk '{print $5}' | tr -d \(\))      <----Why did I even think this implementation could work lmao?
        sshherbe "Lost SSH Connection From IP $IP" &
fi
