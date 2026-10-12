import { useState, useEffect } from 'react';
import io from 'socket.io-client';

export const useCourierTracking = (courierId: string) => {
  const [location, setLocation] = useState<{ latitude: number; longitude: number } | null>(null);

  useEffect(() => {
    const socket = io('http://localhost:5000'); // Update with actual server URL

    socket.on(courier-location-, (data) => {
      setLocation(data);
    });

    return () => {
      socket.disconnect();
    };
  }, [courierId]);

  return location;
};