class InventoryHeading extends TreeData
{
   var Category;
   var IsBasketHeading;
   var IsHeading;
   var IsHorseEquip;
   var IsPlayerInventoryId;
   var Name;
   var UsedPerInventory;
   function InventoryHeading(id, category)
   {
      super(id);
      this.Name = InvEnum.GetItemCategoryName(id);
      this.UsedPerInventory = [];
      this.Category = category;
      this.IsHeading = true;
      this.IsHorseEquip = InvEnum.IsHorseEquip(id);
      this.IsBasketHeading = InvEnum.IsBasketHeading(id);
      this.IsPlayerInventoryId = false;
   }
}
