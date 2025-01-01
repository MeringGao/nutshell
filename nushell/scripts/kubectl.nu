def output-format [] {
    [yaml wide]
}

def 'nu-complete kubectl resources' [] {
    kubectl api-resources|from ssv|get NAME
}

def 'nu-complete kubectl pods' [] {
    kubectl get pods|from ssv|get NAME
}

def 'nu-complete kubectl deploy' [] {
    kubectl get deploy|from ssv|get NAME
}

def kb-detail [resource:string name:string --format(-f):string@"output-format" = ""] {
    if $format == "" {
       let command = $"kubectl get ($resource)/($name) -o wide"
       sh -c $command|from ssv|first
    } else {
     let command =  $"kubectl get ($resource)/($name) -o ($format)"
       sh -c $command|from yaml
    }
}

def kb-logs [resource:string name:string -f] {
       let command = if $f {
               $"kubectl logs ($resource)/($name) -f"
       } else {
               $"kubectl logs ($resource)/($name)"
       }
       echo $command
       nu -c $command
}

def 'kb' [...args] {
    let params = $args | str join " "
    let command = $'kubectl ($params)'
    sh -c $command
}
def 'kb gets' [name:string@"nu-complete kubectl resources" ] {
    kubectl get $name
}

def 'kb get pods' [name?:string@"nu-complete kubectl pods"] {
    let output = kubectl get pods -o wide|from ssv
    $output
}

def 'kb get pod' [name:string@"nu-complete kubectl pods" --format(-f):string@"output-format" = ""] {

    let output = if $format == "" {
       kb-detail pods $name

    } else {
       kb-detail pods $name -f $format
    }
   $output
}

def 'kb get deployments' [name?:string@"nu-complete kubectl deploy"] {
    let output = kubectl get deploy -o wide|from ssv
    $output
}

def 'kb get deploy' [name:string@"nu-complete kubectl deploy" --format(-f):string@"output-format" = ""] {
 # 使用 let 创建命令字符串，更简洁
    let output = if $format != "" {
       kb-detail deploy $name -f $format
    } else {
       kb-detail deploy $name
    }
    $output
}

def 'kb logs pods' [name:string@"nu-complete kubectl pods" -f ] {
    let output = if $f {
      kb-logs pods $name -f
    } else {
      kb-logs pods $name
    }
    $output
}

def 'kb logs deploy' [name:string@"nu-complete kubectl deploy" -f] {
 let output = if $f {
      kb-logs deploy $name -f
    } else {
      kb-logs deploy $name
    }
    $output
}


def 'kb logs' [name:string] {
    kubectl logs $name
}


def kubeexec [name sh:string="bin/bash"] {
    kubectl exec $'(kubectl get pods |from ssv|where NAME =~ $name |get NAME |last)' -c $name -it -- $sh
}

def broker-ide [] {
    kubectl exec $'(kubectl get pods |from ssv|where NAME =~ broker-ide |get NAME |last)' -c broker-ide -it -- /bin/bash -c "cd /home/shanshangao && su shanshangao && exec zsh"
}
