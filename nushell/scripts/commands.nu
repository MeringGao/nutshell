def --env dell-ip [ip:string = '31.200' ] {
    $env.DELL_IP = $ip
}

def --env redmi-ip [ip:string = '31.102' ] {
    $env.REDMI_IP = $ip
}

def --env vpn-ip [ip:string = '31.102' ] {
    $env.VPN_IP = $ip
}

def vpn [] {
    $env.HTTP_PROXY = $'http://192.168.($env.VPN_IP):1082'
    $env.HTTPS_PROXY = $'http://192.168.($env.VPN_IP):1082'
}
def redmi [] {
    ssh $'u0_a309@192.168.($env.REDMI_IP)'
}

def dell [] {
    ssh $'mering@192.168.($env.DELL_IP)'
}

def nfs-mount [] {
    sudo mount -t nfs -o resvport,rw,noowners 192.168.31.200:/home/mering/share/nfs /Users/mering/share/nfs
}

def 'kb pods' [] {
    kubectl get pods
}
def 'kb logs' [name:string] {
    kubectl logs $name
}

def gitac [] {
    git add --all
    git commit -m 'update'
}
def gitp [] {
    git push origin
}
