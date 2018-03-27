提供各类中间件的监控脚本，用于保证服务的可靠性

监控主要是以下的方式：

1，功能监控，主要检测服务的功能可用性

    redis：通过定期向redis写入一个特定的key:value，用于验证redis的核心功能是否正常，且该key的过期时间小于定期写入的时间
    
2，核心指标监控，主要是针对流量，延时，容量，错误四个方面

    流量：total_net_input_bytes   total_net_output_bytes
    
    容量：used_memory     used_cpu_user
