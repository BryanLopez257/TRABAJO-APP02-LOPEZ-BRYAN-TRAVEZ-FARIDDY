using app_02.DTO;
using app2.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace app2.Controllers
{
    [Route("api/medicity/distribuida")]
    [ApiController]
    public class medicityControllers : ControllerBase
    {
        private readonly AppDbContext _context;

        public medicityControllers(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("view")]
        public async Task<IActionResult> GetProductosView()
        {
            var productos = await _context.ConsultaGeneral.ToListAsync();

            return Ok(productos);
        }

        [HttpPost("sp_doctor")]
        public async Task<IActionResult> CrearDoctor(DoctorCrearDto doctor)
        {
            try
            {
                await _context.Database.ExecuteSqlInterpolatedAsync($@"
                EXEC sp_InsertarDoctor
                    @NOMBRE = {doctor.Nombre},
                    @ID_ESPECIALIDAD = {doctor.IdEspecialidad},
                    @ID_CIUDAD = {doctor.IdCiudad}
            ");

                return Ok(new
                {
                    mensaje = "Doctor registrado correctamente"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new
                {
                    mensaje = ex.Message
                });
            }
        }


        [HttpPut("{id}")]
        public async Task<IActionResult> ActualizarCita(
        int id, UpdateCItasDto cita)
        {
            try
            {
                await _context.Database.ExecuteSqlInterpolatedAsync($@"
                EXEC sp_ActualizarCitaMedica
                    @ID = {id},
                    @ID_PACIENTE = {cita.IdPaciente},
                    @ID_DOCTOR = {cita.IdDoctor},
                    @FECHAHORA = {cita.FechaHora}
            ");

                return Ok(new
                {
                    mensaje = "Cita médica actualizada correctamente"
                });
            }
            catch (SqlException ex)
            {
                return BadRequest(new
                {
                    mensaje = ex.Message
                });
            }
        }

        //NUEVOS METODOS: SP UPDATE + VISTAS (PACIENTES)

        [HttpGet("view_pacientes")]
        public async Task<IActionResult> GetPacientesView()
        {
            var pacientes = await _context.PacienteView.ToListAsync();
            return Ok(pacientes);

        }

        [HttpPut("sp_paciente/{id}")]
        public async Task<IActionResult> ActualizarPaciente
             (int id, ActualizarPacienteDto paciente)
        {
            try
            {
                await _context.Database.ExecuteSqlInterpolatedAsync($@"
                EXEC sp_ActualizarPaciente
                    @ID = {id},
                    @NOMBRE = {paciente.Nombre},
                    @FECHA_NACIMIENTO = {paciente.FechaNacimiento},
                    @DIRECCION = {paciente.Direccion},
                    @ID_CIUDAD = {paciente.IdCiudad}
            ");
                return Ok(new { mensaje = "Paciente actualizado correctamente" });
            }
            catch (SqlException ex)
            {
                return BadRequest(new { mensaje = ex.Message });
            }
        }

        //Metodos SP CREATE + VISTA (ESPECIALIDADES)

        [HttpGet("view_especialidades")]
        public async Task<IActionResult> GetEspecialidadesView()
        {
            var especialidades = await _context.EspecialidadView.ToListAsync();
            return Ok(especialidades);
        }

        [HttpPost("sp_especialidades")]
        public async Task<IActionResult> CrearEspecialidad(CrearEspecialidadDto especialidad)
        {
            try
            {
                await _context.Database.ExecuteSqlInterpolatedAsync($@"
                EXEC sp_InsertarEspecialidad
                    @NOMBRE = {especialidad.Nombre}
            ");
                return Ok(new { mensaje = "Especialidad registrada correctamente" });
            }
            catch (Exception ex)
            {
                {
                    return BadRequest(new { mensaje = ex.Message });
                }
            }
        }

        [HttpGet("view_doctores")]
        public async Task<IActionResult> GetDoctoresView()
        {
            var doctores = await _context.DoctorView.ToListAsync();
            return Ok(doctores);
        }

        [HttpGet("view_citaMedica")]
        public async Task<IActionResult> GetCitasView()
        {
            var citas = await _context.CitaMedicaView.ToListAsync();
            return Ok(citas);
        }
    }
}

/*[HttpPost("sp")]
public async Task<IActionResult> CreateProductoSP(Product product)
{
    await _context.Database.ExecuteSqlInterpolatedAsync(
        $"EXEC products_insert_sp @names={product.Names}, @price={product.Price}, @stock={product.Stock}"
    );

    return Ok("Producto creado correctamente");
}*/





