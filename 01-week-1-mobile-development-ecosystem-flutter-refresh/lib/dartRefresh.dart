void main(){
  double p=3.7;
  double l=1.7;
  print('Panjang: $p, Lebar: $l');
  print('Luas persebgi panjang: ${hitungLuasPersegiPanjang(p, l)}');

  String nama='Ilham';
  String nim='24410020139';
  String email1='244107020139@student.polinema.ac.id';
  final profil1=Profil(nama: nama, nim: nim, email: email1);
  print(profil1.info());
  final profil2=Profil(nama: nama, nim: nim);
  print(profil2.info());

}

double hitungLuasPersegiPanjang(double panjang, double lebar) => panjang * lebar;

class Profil{
  Profil({required this.nama, required this.nim, this.email});
  final String nama;
  final String nim;
  String? email;

  String info() => 'Nama: $nama, NIM: $nim, Email: ${email ?? "Belum Diisi"}';
}