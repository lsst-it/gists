#!/bin/bash

getent passwd | while read line; do
  unset params
  declare -a params
  IFS=":" params=($line)
  unset IFS
  user="${params[0]}"
  olduid="${params[2]}"
  oldgid="${params[3]}"

  if [[ $olduid -ge 1000 ]] && ipa user-find --login "$user" 2>/dev/null 1>/dev/null; then
    newuid="$(ipa user-find --login $user | awk '/UID/ { print $2 }')"
    newgid="$(ipa user-find --login $user | awk '/GID/ { print $2 }')"

    echo "${params[0]},${olduid},${oldgid},${newuid},${newgid}"

    find / -uid $olduid \( -fstype xfs -o -fstype ext4 \) -print0 2>&- \
      | xargs -P 100 -n1 -I{} -0 bash -c "chown -h --from=$olduid $newuid '{}'"

    find / -gid $oldgid \( -fstype xfs -o -fstype ext4 \) -print0 2>&- \
      | xargs -P 100 -n1 -I{} -0 bash -c "chown -h --from=:$oldgid :$newuid '{}'"

    userdel $user
  fi
done
