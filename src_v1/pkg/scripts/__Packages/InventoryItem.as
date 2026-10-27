class InventoryItem extends TreeData
{
   var Amount;
   var Blood;
   var BuffDefId;
   var BuffIcon;
   var Category;
   var ClassId;
   var Cost;
   var DataChanged;
   var Dirt;
   var EquipOrder;
   var HashName;
   var Health;
   var HealthState;
   var IconId;
   var Id;
   var InventoryId;
   var IsEnable;
   var IsExpand;
   var IsHorseEquip;
   var IsLeaf;
   var IsMoney;
   var IsNew;
   var IsPlayerInventoryId;
   var IsQuestItem;
   var IsRepainted;
   var IsSelected;
   var MainStat;
   var Name;
   var OutfitPresence;
   var Price;
   var Quality;
   var StackAmount;
   var StackIds;
   var Stolen;
   var Weight;
   var NameKey;
   var HeaderId;
   var IsColourGroup;
   var ColourGroupKey;
   var CgKey;
   var CgTop;
   var CgCount;
   var CgIndent;
   var CgTitleText;
   function InventoryItem(id)
   {
      super(id);
      this.StackIds = [];
      this.InventoryId = InvEnum.INVALID;
      this.IsMoney = false;
   }
   function Set(dataA)
   {
      this.m_SetDataFunc(dataA,0);
      this.DataChanged();
   }
   function m_SetDataFunc(dataA, startIndex)
   {
      this.Name = dataA[startIndex];
      this.NameKey = dataA[startIndex];
      this.ClassId = dataA[startIndex + 1];
      var _loc6_ = dataA[startIndex + 2];
      this.IconId = dataA[startIndex + 3];
      this.Amount = dataA[startIndex + 4];
      this.MainStat = dataA[startIndex + 5];
      this.Health = dataA[startIndex + 6];
      this.Quality = dataA[startIndex + 7];
      this.HealthState = dataA[startIndex + 8];
      this.Weight = dataA[startIndex + 9];
      this.Price = dataA[startIndex + 10];
      this.IsEnable = dataA[startIndex + 11];
      this.OutfitPresence = dataA[startIndex + 12];
      this.IsQuestItem = dataA[startIndex + 13];
      this.IsNew = dataA[startIndex + 14];
      this.Stolen = dataA[startIndex + 15];
      this.Dirt = dataA[startIndex + 16];
      this.Blood = dataA[startIndex + 17];
      this.BuffIcon = dataA[startIndex + 18];
      this.BuffDefId = dataA[startIndex + 19];
      this.IsRepainted = dataA[startIndex + 20];
      var _loc5_ = startIndex + 21;
      if(_loc6_ == InvEnum.CATEGORY_MONEY)
      {
         this.IsMoney = true;
         _loc6_ = InvEnum.CATEGORY_USABLE;
      }
      this.HeaderId = InvEnum.ResolveHeader(this.NameKey,this.IconId,_loc6_);
      this.Category = InvEnum.GetCategoryId(this.HeaderId);
      if(_root.g_Mode == InvEnum.MODE_PLAYER)
      {
         this.InventoryId = dataA[startIndex + 21];
         _loc5_ = startIndex + 22;
      }
      else if(_root.g_Mode == InvEnum.MODE_SHOP_PLAYER)
      {
         this.IsSelected = dataA[startIndex + 21];
         _loc5_ = startIndex + 22;
      }
      else if(_root.g_Mode == InvEnum.MODE_SHOP_TRADER)
      {
         this.IsSelected = dataA[startIndex + 21];
         this.InventoryId = dataA[startIndex + 22];
         this.IsPlayerInventoryId = this.InventoryId == _root.g_PlayerId;
         _loc5_ = startIndex + 23;
      }
      else if(_root.g_Mode >= InvEnum.MODE_FILTER && _root.g_Mode <= InvEnum.MODE_MINIGAME_NO_AMOUNT)
      {
         this.IsSelected = dataA[startIndex + 21];
         if(_root.g_Mode == InvEnum.MODE_REPAIR || _root.g_Mode == InvEnum.MODE_WASH)
         {
            this.Cost = dataA[startIndex + 22];
            _loc5_ = startIndex + 23;
         }
         else
         {
            _loc5_ = startIndex + 22;
         }
      }
      this.Name = TextExtension.translateStringT(this.Name,_root.tfLocal);
      this.HashName = Utils.HashOrder(this.Name);
      this.StackAmount = this.Amount;
      this.IsHorseEquip = InvEnum.IsHorseEquip(this.HeaderId);
      this.EquipOrder = InvEnum.GetEquipOrder(this.OutfitPresence,_root.g_CurrentOutfit);
      return _loc5_;
   }
   function GetStackIds()
   {
      var _loc2_ = this.Id;
      if(this.StackIds.length)
      {
         _loc2_ += "|" + this.StackIds.join("|");
      }
      return _loc2_;
   }
   function UpdateCurrentOutfit(currentOutfit)
   {
      this.EquipOrder = InvEnum.GetEquipOrder(this.OutfitPresence,currentOutfit);
   }
   function ToString()
   {
      var _loc3_ = !this.IsLeaf ? (!this.IsExpand ? "+" : "-") : " ";
      var _loc4_ = this.StackAmount != 0 ? " +" + this.StackAmount : "";
      var _loc2_ = _loc3_ + " " + this.Id + "; " + this.Name + _loc4_ + "; " + "\n";
      return _loc2_;
   }
}
