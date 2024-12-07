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

export extern "kubectl logs" [
  pod: string@"nu-complete kubectl pods"
  --all-containers # Get all containers' logs in the pod(s).
  --all-pods # Get logs from all pod(s). Sets prefix to true.
  --container(-c) # Print the logs of this container
  --follow(-f) # Specify if the logs should be streamed.
  --ignore-errors # If watching / following pod logs, allow for any errors that occur to be non-fatal
  --insecure-skip-tls-verify-backend # Skip verifying the identity of the kubelet that logs are requested from.  In theory, an attacker could provide invalid log content back. You might want to use this if your kubelet serving certificates have expired.
  --limit-bytes:int # Maximum bytes of logs to return. Defaults to no limit.
  --max-log-requests # Specify maximum number of concurrent logs to follow when using by a selector. Defaults to 5.
  --pod-running-timeout:string # The length of time (like 5s, 2m, or 3h, higher than zero) to wait until at least one pod  is running
  --prefix # Prefix each log line with the log source (pod name and container name)
  --previous(-p) # If true, print the logs for the previous instance of the container in a pod if it exists.

  --selector(-l) # Selector (label query) to filter on, supports '=', '==', and '!='.(e.g. -l key1=value1,key2=value2). Matching objects must satisfy all of the specified label constraints.

  --since # Only return logs newer than a relative duration like 5s, 2m, or 3h. Defaults to all logs. Only one of since-time / since may be used.
  --since-time #  Only return logs after a specific date (RFC3339). Defaults to all logs. Only one of since-time / since may be used.
  --tail #Lines of recent log file to display. Defaults to -1 with no selector, showing all log lines otherwise 10, if a selector is provided.
  --timestamps # Include timestamps on each line in the log output
]
