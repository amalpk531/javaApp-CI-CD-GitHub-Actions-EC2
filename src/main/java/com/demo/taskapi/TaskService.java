package com.demo.taskapi;

import org.springframework.stereotype.Service;
import java.util.*;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class TaskService {

    private final Map<Long, Task> store = new HashMap<>();
    private final AtomicLong counter = new AtomicLong(1);

    public List<Task> getAll() {
        return new ArrayList<>(store.values());
    }

    public Task create(Task task) {
        Long id = counter.getAndIncrement();
        task.setId(id);
        store.put(id, task);
        return task;
    }

    public boolean delete(Long id) {
        return store.remove(id) != null;
    }
}
