package com.polinadragun.db.service;

import org.springframework.stereotype.Service;



@Service
public class LoadSimulationService {

    private final QueryService queryService;

    public LoadSimulationService(QueryService queryService) {
        this.queryService = queryService;
    }

    public void simulateLoad(int queryCountToRun) {
        for (int i = 0; i < queryCountToRun; i++) {
            queryService.executeRandomizedQueryBatch();
        }
    }
}