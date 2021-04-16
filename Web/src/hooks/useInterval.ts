import { useEffect, useRef } from 'react';

function useInterval(
  callback: () => void | Promise<void>,
  delay: number | null,
) {
  const savedCallback = useRef<any>();

  // 保存新回调
  useEffect(() => {
    savedCallback.current = callback;
  });

  // 建立 interval
  useEffect(() => {
    function tick() {
      savedCallback.current();
    }
    if (delay !== null) {
      const id = setInterval(tick, delay);
      return () => clearInterval(id);
    }
  }, [delay]);
}

export default useInterval;
