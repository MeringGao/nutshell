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

def kb-detail [resource:string name:string --output(-o):string@"output-format"] {
    let output = if $output != "" {
       let command =  $"kubectl get ($resource)/($name) -o ($output)"
       sh -c $command|from yaml
    } else {
       let command = $"kubectl get ($resource)/($name) -o wide"
       sh -c $command|from ssv|first
    }
    $output
}

def kb-logs [resource:string name:string -f] {

       let command = if $f {
               $"kubectl logs ($resource)/($name) -f"
       } else {
               $"kubectl logs ($resource)/($name)"
       }
       echo $command
       $command

}

def 'kb gets' [name:string@"nu-complete kubectl resources" ] {
    kubectl get $name
}

def 'kb get pods' [name?:string@"nu-complete kubectl pods"] {
    let output = kubectl get pods -o wide|from ssv
    $output
}

def 'kb get pod' [name:string@"nu-complete kubectl pods" --output(-o):string@"output-format"] {
 # 使用 let 创建命令字符串，更简洁
    let output = if $output != "" {
       kb-detail pods $name -o $output
    } else {
       kb-detail pods $name
    }
    $output
}

def 'kb get deployments' [name?:string@"nu-complete kubectl deploy"] {
    let output = kubectl get deploy -o wide|from ssv
    $output
}

def 'kb get deploy' [name:string@"nu-complete kubectl deploy" --output(-o):string@"output-format"] {
 # 使用 let 创建命令字符串，更简洁
    let output = if $output != "" {
       kb-detail deploy $name -o $output
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
