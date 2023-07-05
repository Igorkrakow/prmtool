package com.igt.plt.common;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.nio.charset.StandardCharsets;
import java.util.Set;
import java.util.TreeSet;

/**
 * Purpose of these tool is to guarantee that file tx-draws.csv does not contains records that exists currently in PostgreSql<br/>
 * datamigration will throw an error if it will detect such situation<br/>
 * These can be exported from PostgreSql with this sql<br/>
 * SELECT product_id,draw_id,draw_name,draw_time,draw_status FROM txstore.tx_draws
 *
 * Created by TSENDELA on 2023-02-13.
 */
public class CleanDuplicatesTxDraws {
    private static final Logger LOGGER = LoggerFactory.getLogger(CleanDuplicatesTxDraws.class);
    public static void main(String[] args) throws Exception{
        final Set<String> round001 = new TreeSet<>();
        final Set<String> duplicates = new TreeSet<>();
        try (final BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream("C:\\Users\\tsendela\\Desktop\\trash\\roaming\\logs_roaming\\PLTX\\fafa\\txExport_round_003\\currQ1.csv"), StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                if(line.startsWith("product_id"))continue;
                final String[] split = line.split(",");
                final String product = split[0];
                final String draw = split[1];
                final String unique = product+","+draw;
                round001.add(unique);
            }
        }
        try (final BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream("C:\\Users\\tsendela\\Desktop\\trash\\roaming\\logs_roaming\\PLTX\\fafa\\txExport_round_003\\tx-draws-20230325-150502-003.csv"), StandardCharsets.UTF_8));
             OutputStream outx = new FileOutputStream("C:\\Users\\tsendela\\Desktop\\trash\\roaming\\logs_roaming\\PLTX\\fafa\\txExport_round_003\\tx-draws-20230325-150502-003_corrected.csv");
             Writer out = new OutputStreamWriter(outx, StandardCharsets.UTF_8);
             final BufferedWriter bw = new BufferedWriter(out)
                ) {
            String line;
            while ((line = br.readLine()) != null) {
                if(line.startsWith("product_id")) {
                    bw.append(line).append("\n");
                    bw.flush();
                    continue;
                }
                final String[] split = line.split(",");
                final String product = split[0];
                final String draw = split[1];
                final String unique = product+","+draw;
                if(round001.contains(unique)) {
                    LOGGER.info(unique);
                    duplicates.add(unique);
                }else {
                    bw.append(line).append("\n");
                    bw.flush();
                }
            }
        }
        LOGGER.info(""+duplicates.size());
    }
}
