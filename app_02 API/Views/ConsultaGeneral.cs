namespace app_02.Views
{
    public class ConsultaGeneral
    {

        public long num { get; set; }
        public string paciente { get; set; }
        public DateTime fecha_nacimiento { get; set; }
        public string direccion {  get; set; }
        public string ciudad_paciente { get; set; }
        public string doctor { get; set; }
        public string ciudad_doctor { get; set; }

        public string especialidad { get; set; }

        public DateTime fechahora { get; set; }

        public string descripcion { get; set; }
        public string tratamiento { get; set; }


    }
    /*
        create or alter view consulta_general as
                SELECT 
                row_number () OVER (ORDER BY CM.FECHAHORA) AS num,
                P.NOMBRE PACIENTE, P.FECHA_NACIMIENTO, 
                P.DIRECCION, C.NOMBRE CIUDAD_PACIENTE, D.NOMBRE DOCTOR, cd.nombre ciudad_doctor, E.NOMBRE ESPECIALIDAD,
                CM.FECHAHORA,
                COALESCE(DI.DESCRIPCION,'S/I') DESCRIPCION, COALESCE(DI.TRATAMIENTO,'S/I') TRATAMIENTO
                FROM MEDICITY_A.DBO.CITA_MEDICA_SA CM
                INNER JOIN MEDICITY_A.DBO.PACIENTE_SA P ON P.ID = CM.ID_PACIENTE
                INNER JOIN LS_SITIO_B.MEDICITY_B.DBO.DOCTOR_SB D ON D.ID = CM.ID_DOCTOR
                INNER JOIN MEDICITY_A.DBO.CIUDAD_SA C ON C.ID = P.ID_CIUDAD
                INNER JOIN MEDICITY_A.DBO.CIUDAD_SA CD ON CD.ID = D.ID_CIUDAD
                INNER JOIN LS_SITIO_B.MEDICITY_B.DBO.ESPECIALIDAD_SB E ON E.ID = D.ID_ESPECIALIDAD
                LEFT JOIN LS_SITIO_B.MEDICITY_B.DBO.DIAGNOSTICO_SB DI ON DI.ID_CITA = CM.ID;

        select * from consulta_general
     
     
     * */

}
