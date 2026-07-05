class Cuidador extends Usuario {
   Cuidadores({
     required String nombre,
     required DateTime fechaNacimiento,
     String? fotoPerfil,
   }) : super(
         nombre: nombre,
         fechaNacimiento: fechaNacimiento,
         fotoPerfil: fotoPerfil,
       );