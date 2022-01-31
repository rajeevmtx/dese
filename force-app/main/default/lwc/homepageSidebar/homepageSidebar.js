import { LightningElement, api , track} from 'lwc';

export default class HomepageSidebar extends LightningElement {
    // @api stageNum;
    connectedCallback() {
          console.log("stageNum SideBar: ", this.stageNum);
      }
      handleUserClicks(event) {
        let selected = event.target.value;

        const eventX = new CustomEvent("child", {
            detail: { stageNo: selected, prevStageNo: this.stageNum },
        });
        this.dispatchEvent(eventX);
    }
    get isActive1() {
        if (this.stageNum == "1") return 'active';
        return '';
      }
      get isActive2() {
        if (this.stageNum == "2") return 'active';
        return '';
      }
      get isActive3() {
        if (this.stageNum == "3") return 'active';
        return '';
      }
}