// repo/AlertRepository.java
package com.fireshield.server.repo;
import com.fireshield.server.domain.Alert;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AlertRepository extends JpaRepository<Alert, Long> {}
