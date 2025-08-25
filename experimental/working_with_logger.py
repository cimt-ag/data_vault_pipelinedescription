import logging

def my_function():
    logger.info("This is my info", )
    logger.warning("This is my warning")
    logger.error("This is my warning")

formatter = logging.Formatter('%(asctime)s|%(levelname)s|%(name)s: %(message)s')
log_stream_handler = logging.StreamHandler()
log_stream_handler.setFormatter(formatter)

logger = logging.getLogger('datachecker')
logger.setLevel(logging.INFO)
logger.addHandler(log_stream_handler)
my_function()

