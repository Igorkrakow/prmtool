/*
 * Copyright © 2023 IGT.
 *
 * This software and all information contained therein is confidential and proprietary
 * and shall not be duplicated, used, disclosed or disseminated in any way except as
 * authorized by the applicable license agreement, without the express written permission of IGT.
 * All authorized reproductions must be marked with this language.
 */
package com.igt.plt;

import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.batch.core.ExitStatus;
import org.springframework.batch.core.JobExecution;
import org.springframework.batch.core.JobParametersInvalidException;
import org.springframework.batch.core.explore.JobExplorer;
import org.springframework.batch.core.launch.JobInstanceAlreadyExistsException;
import org.springframework.batch.core.launch.JobOperator;
import org.springframework.batch.core.launch.NoSuchJobException;
import org.springframework.context.support.ClassPathXmlApplicationContext;

/**
 * Created by TSENDELA on 2023-01-24.
 */
public class PltCsvExporter {
    private static final Logger LOGGER = LoggerFactory.getLogger(PltCsvExporter.class);

    @SuppressWarnings("resource")
    public static void main(String[] args) throws JobInstanceAlreadyExistsException, NoSuchJobException, JobParametersInvalidException {
        final String jobName = args[0];
        final String commit = args[1];
        final String outPath = args[2];
        final String exportRound = args[3];
        final List<String> batches = Arrays.asList("subExport", "favExport", "txExport");
        final boolean contains = batches.contains(jobName);
        if (!contains) {
            LOGGER.error("jobName argument is incorrect {}, should be of of {}", jobName, batches);
            return;
        }
        LOGGER.info("Batch started with argumets commit={}", commit);
        final ClassPathXmlApplicationContext ctx = new ClassPathXmlApplicationContext("spring.xml");
        final JobOperator jobOperator = (JobOperator) ctx.getBean("jobOperator");
        final SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd-HHmmss");
        final Date now = new Date();
        final long executionId;
        if ("subExport".equals(jobName)) {
            final String subFileName = outPath + "/dgsubscription-" + sdf.format(now) + "-" + exportRound + ".csv";
            final String swtFileName = outPath + "/dgsubs-wager-template-" + sdf.format(now) + "-" + exportRound + ".csv";
            final String bsFileName = outPath + "/dgboardstack-" + sdf.format(now) + "-" + exportRound + ".csv";
            final String bFileName = outPath + "/dgboard-" + sdf.format(now) + "-" + exportRound + ".csv";
            final String batchArgs = getUniqueInstanceId(jobName) + ",COMMIT:" + commit //
                    + ",SUBFILEPATH:" + subFileName //
                    + ",SWTFILEPATH:" + swtFileName //
                    + ",BSFILEPATH:" + bsFileName //
                    + ",BFILEPATH:" + bFileName //
                    ;
            executionId = jobOperator.start(jobName, batchArgs);
        } else if ("favExport".equals(jobName)) {
            final String favFileName = outPath + "/favorite-wager-" + sdf.format(now) + "-" + exportRound + ".csv";
            final String favBsFileName = outPath + "/favorite-stack-" + sdf.format(now) + "-" + exportRound + ".csv";
            final String favBFileName = outPath + "/favorite-board-" + sdf.format(now) + "-" + exportRound + ".csv";
            final String batchArgs = getUniqueInstanceId(jobName) + ",COMMIT:" + commit //
                    + ",FAVFILEPATH:" + favFileName //
                    + ",FAVBSFILEPATH:" + favBsFileName //
                    + ",FAVBFILEPATH:" + favBFileName //
                    ;
            executionId = jobOperator.start(jobName, batchArgs);
        } else {
            final String txTransactionFileName = outPath + "/tx-transaction-" + sdf.format(now) + "-" + exportRound + ".csv";
            final String txTransactionJsonFileName = outPath + "/json-transaction-" + sdf.format(now) + "-" + exportRound + ".csv";
            final String txDrawEntryFileName = outPath + "/tx-draw-entry-" + sdf.format(now) + "-" + exportRound + ".csv";
            final String txDrawsFileName = outPath + "/tx-draws-" + sdf.format(now) + "-" + exportRound + ".csv";
            final String txResultFileName = outPath + "/tx-result-" + sdf.format(now) + "-" + exportRound + ".csv";
            final String batchArgs = getUniqueInstanceId(jobName) + ",COMMIT:" + commit //
                    + ",TXTRANSACTIONFILEPATH:" + txTransactionFileName //
                    + ",TXTRANSACTIONJSONFILEPATH:" + txTransactionJsonFileName //
                    + ",TXDRAWENTRYFILEPATH:" + txDrawEntryFileName //
                    + ",TXDRAWSFILEPATH:" + txDrawsFileName //
                    + ",TXRESULTFILEPATH:" + txResultFileName //
                    ;
            executionId = jobOperator.start(jobName, batchArgs);
        }
        LOGGER.debug("execution id=" + executionId);
        final JobExplorer jobExplorer = (JobExplorer) ctx.getBean("jobExplorer");
        final JobExecution jobExecution = jobExplorer.getJobExecution(executionId);
        LOGGER.debug("jobExecution=" + jobExecution);
        LOGGER.info("exitStatus=" + jobExecution.getExitStatus());
        if (ExitStatus.FAILED.getExitCode().equals(jobExecution.getExitStatus().getExitCode())) {
            LOGGER.error("exitStatus=" + jobExecution.getExitStatus());
            System.exit(2);
        }
    }

    private static String getUniqueInstanceId(String jobName) {
        return String.format(",uniqueInstanceId=%s", String.format("%s:%s", jobName, UUID.randomUUID()));
    }
}
