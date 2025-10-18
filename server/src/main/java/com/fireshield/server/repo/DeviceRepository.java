// repo/DeviceRepository.java
package com.fireshield.server.repo;
import com.fireshield.server.domain.Device;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface DeviceRepository extends JpaRepository<Device, UUID> {
  Optional<Device> findByDeviceKey(String deviceKey);
}
