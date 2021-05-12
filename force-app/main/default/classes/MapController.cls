public class MapController {

public MapController() {
account a = [select id,name,SLA__c from account limit 1];
   regMap = new Map<String, account>();
   regMap.put('a', a);
   regMap.put('b', a);
   regMap.put('c', a);
   keys = new List<String>{'a', 'b', 'c'};
   
}

public Map<String, account> regMap {get; set;}

public List<String> keys {get ; set;}

}