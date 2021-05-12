global class TFSInfoClass implements Process.Plugin
{    
    global Process.PluginResult invoke(Process.PluginRequest request)
    {   
        Map<String, Object> result = new Map<String, Object>();  
        
        List<TwoFactorInfo> twoFactors = [SELECT UserId, Type FROM TwoFactorInfo where userID = :userInfo.getUserId()];
        result.put('Has Registered Token', !TwoFactors.isEmpty());

        return new Process.PluginResult(result);
    }

    global Process.PluginDescribeResult describe()
    {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.description='This plug-in generates a radnom 5-digits code';
        result.tag='Identity';
        
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter> {};
        
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter> {
            new Process.PluginDescribeResult.OutputParameter('Has Registered Token',
                Process.PluginDescribeResult.ParameterType.Boolean)
        };
           
        return result;
    }
}