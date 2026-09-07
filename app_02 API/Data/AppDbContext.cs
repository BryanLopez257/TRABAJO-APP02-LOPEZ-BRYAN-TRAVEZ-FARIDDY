using app_02.DTO;
using app_02.Views;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace app2.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(
        DbContextOptions<AppDbContext> options)
        : base(options)
        {

        }
        public DbSet<ConsultaGeneral> ConsultaGeneral { get; set; }
        public DbSet<PacienteView> PacienteView { get; set; }
        public DbSet<EspecialidadView> EspecialidadView { get; set; }
        public DbSet<DoctorView> DoctorView { get; set; }
        public DbSet<CitaMedicaView> CitaMedicaView { get; set; }
       
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<ConsultaGeneral>(entity =>
            {
                entity.HasNoKey();
                entity.ToView("consulta_general");
            });

            modelBuilder.Entity<PacienteView>(entity =>
            {
                entity.HasNoKey();
                entity.ToView("vw_Pacientes_SitioA");
            });

            modelBuilder.Entity<EspecialidadView>(entity =>
            {
                entity.HasNoKey();
                entity.ToView("vw_Especialidades_SitioB");
            });

            modelBuilder.Entity<DoctorView>(entity =>
            {
                entity.HasNoKey();
                entity.ToView("vw_Doctores_SitioA");
            });

            modelBuilder.Entity<CitaMedicaView>(entity =>
            {
                entity.HasNoKey();
                entity.ToView("vw_Citas_Actualizadas");
            });
        }

    }
}
