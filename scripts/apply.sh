#!/usr/bin/env bash

ENTERPRISE_REPO_LIST="/etc/apt/sources.list.d/pve-enterprise.list"
JSLIBFILE="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"

function pve_patch() {
  echo "- apply patch..."
  [ -f $ENTERPRISE_REPO_LIST ] && mv $ENTERPRISE_REPO_LIST $ENTERPRISE_REPO_LIST~

  # (6.1 and up)
  sed -i.backup "s/data.status !== 'Active'/false/g" ${JSLIBFILE}
  # (6.2-11 and up)
  sed -i.backup -z "s/res === null || res === undefined || \!res || res\n\t\t\t.false/false/g" ${JSLIBFILE}
  # (6.2-12 and up)
  sed -i.backup -z "s/res === null || res === undefined || \!res || res\n\t\t\t.data.status \!== 'Active'/false/g" ${JSLIBFILE}
  # (6.2-15 6.3-2 6.3-3 6.3-4 6.3-6 and up)
  sed -i.backup -z "s/res === null || res === undefined || \!res || res\n\t\t\t.data.status.toLowerCase() \!== 'active'/false/g" ${JSLIBFILE}
  # general case
  sed -i.backup -z "s/res.data.status.toLowerCase() \!== 'active'/false/g" ${JSLIBFILE}

  systemctl restart pveproxy.service
}

pve_patch
