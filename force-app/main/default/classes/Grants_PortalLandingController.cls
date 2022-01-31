public class Grants_PortalLandingController {

    public Account acc { get; set; }
    public List<MenuItem> lstMenuItems { get; set; }
    public Grants_PortalLandingController() {
        acc = [select id,Name from account limit 1];
        lstMenuItems = new List<MenuItem>();
        lstMenuItems.add(new MenuItem('Grants Listing', 'Review your provider and license information as well as the past and current transactions.', ' fa-bar-chart', 'EEC_PortalProviderPage?member=' + acc.Id));
        lstMenuItems.add(new MenuItem('Proposal Listing', 'Review your provider and license information as well as the past and current transactions.', 'fa-list', 'EEC_PortalProviderPage?member=' + acc.Id));
        lstMenuItems.add(new MenuItem('My Project', 'Test Project.', 'fa-list','Core_Project_ListView_Page'));

    }

    public class MenuItem {
        public string name { get; set; }
        public string description { get; set; }
        public string icon { get; set; }
        public string destination { get; set; }

        public MenuItem(string name, string description, string icon, string destination) {
            this.name = name;
            this.description = description;
            this.icon = icon;
            this.destination = destination;
        }
    }

}