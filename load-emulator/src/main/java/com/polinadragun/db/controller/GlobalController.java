package com.polinadragun.db.controller;

import com.polinadragun.db.service.LoadSimulationService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/simulator")
public class GlobalController {

    private final LoadSimulationService simulationService;

    public GlobalController(LoadSimulationService simulationService) {
        this.simulationService = simulationService;
    }

    @PostMapping("/load")
    public ResponseEntity<String> simulate() {
        simulationService.simulateLoad(100);
        return ResponseEntity.ok("Simulated queries.");
    }
}
