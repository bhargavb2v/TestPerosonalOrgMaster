public class TestSelectListDemoController {
    public string selectedCity{get;set;}
    public string selectedState{get;set;}
    public string profile{get;set;}
    
    public TestSelectListDemoController(){
        profile='ABC';
    }
    
    public List<SelectOption> getstateList() {
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new selectoption('', '-None-'));
        
        options.add(new selectoption('TS', 'TS'));
        options.add(new selectoption('All State', 'All State'));
        options.add(new selectoption('Summary State','Summary State'));      
        return options;
     }
    
     public List<SelectOption> getcityList() {
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new selectoption('', '-None-'));
        if(selectedState == 'TS'){
            options.add(new selectoption('Hyd', 'Hyd'));
        }
        
        options.add(new selectoption('All', 'All'));
        options.add(new selectoption('Summary','Summary'));      
        return options;
     }
     
     public void stateChange(){
         system.debug('## State ## '+selectedState);
     }
     public void cityChange(){
         system.debug('## City ## '+selectedCity);
     }
}