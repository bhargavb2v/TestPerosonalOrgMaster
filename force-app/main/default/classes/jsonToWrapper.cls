Public Class jsonToWrapper{
    public jsonToWrapper(){
        String str = '{"NRC":0.00,"MRC":40.00}';
        wrapper lst = (wrapper)System.JSON.deserialize(str, wrapper.class);
        system.debug('###'+lst.MRC);
    }
    
    public class wrapper{
        public decimal NRC;
        public decimal MRC;
    }

}