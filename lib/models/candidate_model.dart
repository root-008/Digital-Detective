class Candidate {
  final String id;
  final String name;
  final String gender; 
  final int qualificationScore; 
  bool isHired;

  Candidate({
    required this.id,
    required this.name,
    required this.gender,
    required this.qualificationScore,
    this.isHired = false,
  });
}