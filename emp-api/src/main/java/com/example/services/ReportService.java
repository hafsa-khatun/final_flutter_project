package com.example.services;

import net.sf.jasperreports.engine.JasperExportManager;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrint;
import net.sf.jasperreports.engine.JasperReport;
import net.sf.jasperreports.engine.util.JRLoader;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.io.InputStream;
import java.sql.Connection;
import java.util.Map;
@Service
public class ReportService {
    final private DataSource dataSource;

    public ReportService(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public byte[] generateReport(String reportName, Map<String, Object> params) throws Exception {

        //To read Jasper file
        InputStream is = new ClassPathResource("reports/" + reportName + ".jasper").getInputStream();
        //Load the input stream in Jasper Object
        JasperReport jr = (JasperReport) JRLoader.loadObject(is);
        //Get the connection of Datasource
        Connection con = dataSource.getConnection();
        //Prepare the Report to print
        JasperPrint jp = JasperFillManager.fillReport(jr,params,con);
        con.close();
        // return byte[]
        return JasperExportManager.exportReportToPdf(jp);
    }
}
