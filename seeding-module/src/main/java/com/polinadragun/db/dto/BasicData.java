package com.polinadragun.db.dto;

import lombok.Data;

import java.util.List;

@Data
public class BasicData {

    private List<Role> roles;
    private List<Region> regions;
    private List<Specialization> specializations;

    @Data
    public static class Role {
        private String role_code;
        private boolean requires_legal_profiles;
    }

    @Data
    public static class Region {
        private String region_code;
        private String name;
    }

    @Data
    public static class Specialization {
        private String spec_code;
        private String name;
    }
}
