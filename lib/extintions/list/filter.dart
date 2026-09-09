
// المحاضر عمل "مصفاة ذكية" مدمجة في مواسير الـ 
//Streams. بمجرد ما يركب المصفاة دي، الملاحظات هتدخل من ناحية الداتابيز مختلطة، وتطلع من الناحية التانية للشاشة متفلترة ونظيفة ومفيهاش غير ملاحظات المستخدم الحالي بس!


extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) where) =>
      map((items) => items.where(where).toList());
}
