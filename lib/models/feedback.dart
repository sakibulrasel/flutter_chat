class FeedBack{
  String name;
  String feedback;

  FeedBack(this.name,this.feedback);


  // Method to make GET parameters.
  String toParams() =>
      "?name=$name&feedback=$feedback";
}