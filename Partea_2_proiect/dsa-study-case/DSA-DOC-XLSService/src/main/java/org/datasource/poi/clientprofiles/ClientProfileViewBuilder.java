package org.datasource.poi.clientprofiles;

import org.apache.poi.ss.usermodel.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ClientProfileViewBuilder {

    @Value("${xlsx.data.source.file.path}")
    private String xlsxFilePath;

    private List<ClientProfileView> viewList = new ArrayList<>();

    public List<ClientProfileView> getViewList() {
        return this.viewList;
    }

    public ClientProfileViewBuilder build() throws Exception {
        this.viewList = new ArrayList<>();

        try (InputStream inputStream = openInputStream();
             Workbook workbook = WorkbookFactory.create(inputStream)) {

            Sheet sheet = workbook.getSheetAt(0);
            DataFormatter formatter = new DataFormatter();

            Row headerRow = sheet.getRow(0);
            Map<String, Integer> columns = new HashMap<>();

            for (Cell cell : headerRow) {
                String columnName = formatter.formatCellValue(cell)
                        .trim()
                        .toLowerCase()
                        .replace(" ", "_");
                columns.put(columnName, cell.getColumnIndex());
            }

            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) {
                    continue;
                }

                Integer clientId = getInteger(row, columns, formatter, "client_id", "clientid", "id");
                Integer age = getInteger(row, columns, formatter, "age");
                String job = getString(row, columns, formatter, "job");
                String marital = getString(row, columns, formatter, "marital");
                String education = getString(row, columns, formatter, "education");
                BigDecimal balance = getBigDecimal(row, columns, formatter, "balance");
                String housing = getString(row, columns, formatter, "housing");
                String loan = getString(row, columns, formatter, "loan");

                if (clientId == null && age == null && job == null) {
                    continue;
                }

                this.viewList.add(new ClientProfileView(
                        clientId,
                        age,
                        job,
                        marital,
                        education,
                        balance,
                        housing,
                        loan
                ));
            }
        }

        return this;
    }

    private InputStream openInputStream() throws Exception {
        File file = new File(xlsxFilePath);

        if (file.exists()) {
            return Files.newInputStream(file.toPath());
        }

        return new ClassPathResource(xlsxFilePath).getInputStream();
    }

    private String getString(Row row, Map<String, Integer> columns, DataFormatter formatter, String... names) {
        Integer index = findColumn(columns, names);
        if (index == null) {
            return null;
        }

        Cell cell = row.getCell(index);
        if (cell == null) {
            return null;
        }

        String value = formatter.formatCellValue(cell);
        return value == null ? null : value.trim();
    }

    private Integer getInteger(Row row, Map<String, Integer> columns, DataFormatter formatter, String... names) {
        String value = getString(row, columns, formatter, names);
        if (value == null || value.isBlank()) {
            return null;
        }

        try {
            return Integer.parseInt(value.replace(".0", "").trim());
        } catch (Exception e) {
            return null;
        }
    }

    private BigDecimal getBigDecimal(Row row, Map<String, Integer> columns, DataFormatter formatter, String... names) {
        String value = getString(row, columns, formatter, names);
        if (value == null || value.isBlank()) {
            return null;
        }

        try {
            value = value.replace(",", ".").trim();
            return new BigDecimal(value);
        } catch (Exception e) {
            return null;
        }
    }

    private Integer findColumn(Map<String, Integer> columns, String... names) {
        for (String name : names) {
            String normalized = name.toLowerCase().replace(" ", "_");
            if (columns.containsKey(normalized)) {
                return columns.get(normalized);
            }
        }
        return null;
    }
}