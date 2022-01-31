public class psrChatterHandler {

    public string recordid {get;set;}


    public psrChatterHandler() {
        System.debug('Id in record : ' + ApexPages.currentPage().getParameters().get('id'));
        recordid = ApexPages.currentPage().getParameters().get('id');
    }
}