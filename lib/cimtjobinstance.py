"""

Class to manage job instances

"""
import psycopg2
import socket
import sys
import os
import getpass
from datetime import datetime
from lib.config_pg_data_warehouse import pg_data_warehouse_getConnection, DwhConnectionType
from pathlib import PurePath

JOB_INSTANCE_STATUS_TABLE_NAME = 'metadata.job_instance_status'
JOB_INSTANCE_ID_SEQUENCE_EXPRESSION = "nextval('metadata.job_instance_status_job_instance_id_seq')"


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


class CimtJobInstance:
    """Object to manage the logging of a job instance according to the cimt job instance concept"""

    def __init__(self, _job_name, parent_instance=None):

        self._parent_instance = parent_instance
        dot_index = _job_name.rfind(".")
        if dot_index == -1:
            self._job_name = _job_name
        elif _job_name[dot_index:] == ".py":
            self._job_name = _job_name[:-3]
        else:
            self._job_name = _job_name

        if self._parent_instance is not None:
            self._parent_id = self._parent_instance._job_instance_id
            self._process_instance_id = self._parent_instance._process_instance_id
            self._process_instance_name = self._parent_instance._process_instance_name
        else:
            self._parent_id = -1
            self._process_instance_id = None
            self._process_instance_name = self._job_name

        self._job_instance_id = None  # Will be also used as flag to determine if job instance has started
        self._job_started_at = None
        self._job_ended_at = None

        self._return_code = None
        self._return_message = None

        self._hostname = str(socket.gethostname())
        self._user = getpass.getuser()
        self._host_pid = os.getpid()

        self._metadata_dict = {}  # This is the storage of all other metadata about the instance
        self._ended = False  # Flag to indicate the successful processing of the end_instance

    def __str__(self):
        return str(self._job_instance_id)

    def start_instance(self):
        """Record the start of the instance in the data base"""
        if self._job_instance_id is not None:
            raise Exception("You can't start a job instance twice")

        self._job_started_at = datetime.now()
        conn = pg_data_warehouse_getConnection(DwhConnectionType.metadata)
        cur = conn.cursor()
        cur.execute(f"SELECT {JOB_INSTANCE_ID_SEQUENCE_EXPRESSION};")

        rows = cur.fetchall()

        self._job_instance_id = rows[0][0]
        if self._process_instance_id is None:
            self._process_instance_id = self._job_instance_id

        insert_statement_columns = """job_instance_id, parent_id, process_instance_id,
                                job_started_at, job_name, process_instance_name,
                                host_name,host_user,host_pid"""

        insert_statement_values = f"""{self._job_instance_id}, {self._parent_id},{self._process_instance_id} ,
                                      '{self._job_started_at}', '{self._job_name}','{self._process_instance_name}', 
                                      '{self._hostname}','{self._user}',{self._host_pid} """

        for meta_column_name in self._metadata_dict:
            if self._metadata_dict[meta_column_name] is not None:
                insert_statement_columns += "," + meta_column_name
                insert_statement_values += f",'{self._metadata_dict[meta_column_name]}'"

        statement = f"""INSERT INTO {JOB_INSTANCE_STATUS_TABLE_NAME} ({insert_statement_columns}) 
                      VALUES ({insert_statement_values});"""

        cur.execute(statement)
        cur.close()
        conn.commit()
        conn.close()

        tag = os.getenv('BASE_TAG', 'local run')
        print(self._job_started_at, "job_instance of '", self._job_name, 'tag_key:', tag,
              "' started with job_instance_id:", self._job_instance_id, "parent_id:", self._parent_id)

    def get_job_instance_id(self):
        """returns the job_instance_id of this instance"""
        if self._job_instance_id is None:
            raise Exception('Job instance has not been started yet')
        return self._job_instance_id

    def get_process_instance_name(self):
        """returns the process_instance_name of this instance"""
        if self._process_instance_name is None:
            raise Exception('Job instance has not been started yet')
        return self._process_instance_name

    def get_job_started_at(self):
        """returns the process_instance_name of this instance"""
        if self._job_started_at is None:
            raise Exception('Job instance has not been started yet')
        return self._job_started_at

    def get_job_ended_at(self):
        """returns the job_ended_at time  of this instance (can be none if instances is running or ended not properly"""
        return self._job_ended_at

    def get_return_code(self):
        """returns the return_code of this instance"""
        return self._return_code

    def set_work_item(self, work_item):
        """declare the work item of the instance (use before start or end)"""
        self._metadata_dict['work_item'] = work_item

    def get_work_item(self):
        """retreive the work item of the instance """
        if 'work_item' in self._metadata_dict:
            return self._metadata_dict['work_item']
        else:
            return None

    def set_time_range(self, time_range_start, time_range_end=None):
        """declare the processed time range of the instance (use before start or end)"""
        self._metadata_dict['time_range_start'] = time_range_start
        self._metadata_dict['time_range_end'] = time_range_end

    def get_time_range_start(self):
        if 'time_range_start' in self._metadata_dict:
            return self._metadata_dict['time_range_start']
        else:
            return None

    def get_time_range_end(self):
        if 'time_range_end' in self._metadata_dict:
            return self._metadata_dict['time_range_end']
        else:
            return None

    def set_value_range(self, value_range_start, value_range_end=None):
        """declare the processed value range of the instance (use before start or end)"""
        self._metadata_dict['value_range_start'] = value_range_start
        self._metadata_dict['value_range_end'] = value_range_end

    def get_value_range_start(self):
        return self._metadata_dict.get('value_range_start')

    def get_value_range_end(self):
        return self._metadata_dict.get('value_range_end')

    def count_input(self, count_number: int):
        """Adds number to input counter"""
        self._add_count_to_meta_dict('count_input', count_number)

    def count_output(self, count_number: int):
        """Adds number to output counter"""
        self._add_count_to_meta_dict('count_output', count_number)

    def count_rejected(self, count_number: int):
        """Adds number to rejected counter"""
        self._add_count_to_meta_dict('count_rejected', count_number)

    def count_ignored(self, count_number: int):
        """Adds number to ignored counter"""
        self._add_count_to_meta_dict('count_ignored', count_number)

    def _add_count_to_meta_dict(self, dict_key, count_number: int):
        if dict_key in self._metadata_dict:
            self._metadata_dict[dict_key] += count_number
        else:
            self._metadata_dict[dict_key] = count_number

    def get_count_input(self):
        if 'count_input' in self._metadata_dict:
            return self._metadata_dict['count_input']
        else:
            return None

    def get_count_output(self):
        if 'count_output' in self._metadata_dict:
            return self._metadata_dict['count_output']
        else:
            return None

    def end_instance(self):
        """Record the normal ending of the job instance"""
        self._end_instance(self._job_instance_id, 0, "")
        print(f"job_instance end_instance of '{self._job_name}' job_instance_id:{self._job_instance_id}")

    def end_instance_with_error(self, return_code, return_message=None):
        """Record the abnormal ending of the job instance"""
        self._end_instance(self._job_instance_id, return_code, return_message)
        print("job_instance end instance of '", self._job_name,
              "' job_instance_id:", self._job_instance_id,
              "with error '", return_message[0:200], "'")

    def _end_instance(self, job_instance_id, return_code, return_message=None):
        """Assemble final data of instance and update the table row"""
        if self._ended:
            raise Exception("You can't end a job instance twice")

        if self._job_instance_id is None:
            raise Exception('Job instance has not been started yet')

        self._job_ended_at = datetime.now()
        self._return_code = return_code

        conn = None
        try:
            conn = pg_data_warehouse_getConnection(DwhConnectionType.metadata)
            cur = conn.cursor()

            statement = f"""UPDATE {JOB_INSTANCE_STATUS_TABLE_NAME}
                            SET job_ended_at  = '{self._job_ended_at}',
                                return_code = {self._return_code}"""

            if return_message is not None:
                statement += f""" ,return_message='{return_message}' """

            for meta_column_name in self._metadata_dict:
                if type(self._metadata_dict[meta_column_name]) == "<type 'int'>":
                    statement += f""", {meta_column_name}={self._metadata_dict[meta_column_name]}"""
                elif self._metadata_dict[meta_column_name] is not None:
                    statement += f""", {meta_column_name}='{self._metadata_dict[meta_column_name]}'"""

            statement += f"""WHERE job_instance_id = {job_instance_id};"""

            cur.execute(statement)

            # close communication with the PostgreSQL database server
            cur.close()
            # commit the changes
            conn.commit()
            self._ended = True  # After successful storing, this instance really ended

        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
            raise

        finally:
            if conn is not None:
                conn.close()

        return job_instance_id

    def load_previous_instance(self, was_successful=True, had_input_data=False, had_output_data=False, restrict_to_workitem=None):
        """Check for previous metadata in job_instance status table and loads it into this object.
           Returns True if successful else False"""

        db_connection = pg_data_warehouse_getConnection(DwhConnectionType.metadata)
        db_cursor = db_connection.cursor()
        statement = f"""select job_instance_id 
                        from {JOB_INSTANCE_STATUS_TABLE_NAME}
                        where (job_name,job_started_at) in (
                        select job_name,max(job_started_at) 
                        from {JOB_INSTANCE_STATUS_TABLE_NAME}
                        where job_name='{self._job_name}'"""

        if was_successful:
            statement += " AND return_code=0"

        if had_input_data:
            statement += " AND count_input>0"

        if had_output_data:
            statement += " AND count_output>0"

        if restrict_to_workitem:
            statement += f" AND work_item='{restrict_to_workitem}'"

        statement += " GROUP BY 1)"
        # print(statement)
        db_cursor.execute(statement)
        result_row = db_cursor.fetchone()
        db_cursor.close()

        if result_row is not None:
            prev_job_instance_id = result_row[0]
            self.load_data_from_table(db_connection, prev_job_instance_id)
            db_connection.close()
            return True

        db_connection.close()
        return False

    def load_data_from_table(self, db_connection, job_instance_id):
        """Check for previous metadata in job_instance status table and return a CimtJobInstance
        with that data (returns None if not found)"""

        if self._job_instance_id is not None:
            raise Exception("Cant load data into job instance, when already started/loaded")

        db_cursor = db_connection.cursor()
        statement = f""" SELECT job_instance_id, process_instance_id, parent_id, 
                        process_instance_name, job_name, 
                        work_item, time_range_start, time_range_end, 
                        value_range_start, value_range_end, 
                        job_started_at, job_ended_at, 
                        count_input, count_output, count_rejected, count_ignored, 
                        return_code, return_message, host_name, host_pid, host_user
                        FROM {JOB_INSTANCE_STATUS_TABLE_NAME}
                        where job_instance_id={job_instance_id}"""

        db_cursor.execute(statement)
        result_row = db_cursor.fetchone()
        db_cursor.close()

        if result_row is not None:
            self._job_instance_id = result_row[0]
            self._process_instance_id = result_row[1]
            self._parent_id = result_row[2]
            self._process_instance_name = result_row[3]
            self._job_name = result_row[4]
            self._metadata_dict['work_item'] = result_row[5]
            self._metadata_dict['time_range_start'] = result_row[6]
            self._metadata_dict['time_range_end'] = result_row[7]
            self._metadata_dict['value_range_start'] = result_row[8]
            self._metadata_dict['value_range_end'] = result_row[9]
            self._job_started_at = result_row[10]
            self._job_ended_at = result_row[11]
            self._metadata_dict['count_input'] = result_row[12]
            self._metadata_dict['count_output'] = result_row[13]
            self._metadata_dict['count_rejected'] = result_row[14]
            self._metadata_dict['count_ignored'] = result_row[15]
            self._return_code = result_row[16]
            self._return_message = result_row[17]
            self._hostname = result_row[18]
            self._host_pid = result_row[19]
            self._user = result_row[20]


def cimtjobinstance_job(f):
    """
    This decorator can be used to mark an ETL job.

    Injects the `instance_job_name` into the `kwargs`.
    The instance_job_name is the combination of the stem of file name in which the decorated function resides
    (i. e. the filename wihtout the extension)
    and the name of the parent folder. The structure is f'{parent_folder}_{file_name_stem}'.
    """

    def cimtjobinstance_job_decorator(*args, **kwargs):
        import inspect

        function_path = inspect.getfile(f)
        ppath = PurePath(function_path)
        print('cimtjobinstance_job:', ppath.parent.name)
        if ppath.stem != "__main__":
            etl_job_name = '.'.join([ppath.parent.name, ppath.stem, f.__name__])
        else:
            etl_job_name = '.'.join([ppath.parent.name, f.__name__])

        kwargs['instance_job_name'] = etl_job_name
        return f(*args, **kwargs)

    return cimtjobinstance_job_decorator


@cimtjobinstance_job
def demonstration_and_test_of_CimtJobInstance(**kwargs):
    name_of_this_module = kwargs['instance_job_name']
    job_instance_master = CimtJobInstance(name_of_this_module)

    prev_job_instance = CimtJobInstance(name_of_this_module)
    if prev_job_instance.load_previous_instance():
        print("Prev job_instance_id", prev_job_instance.get_job_instance_id())
        print("Prev get_work_item", prev_job_instance.get_work_item())
        print("Prev get_count_output", prev_job_instance.get_count_output())

    try:
        prev_job_instance.load_previous_instance()  # assertion test,
        raise Exception('load_previous_instance did not fail, but was expected to')
    except (Exception) as Error:
        print("Expected Exception:", Error)

    job_instance_master.set_work_item("mocked work item of " + name_of_this_module)
    job_instance_master.start_instance()
    # job_instance_master.load_previous_instance() # assertion test, uncomment to test

    job_instance1 = CimtJobInstance('Job  1', job_instance_master)
    job_instance1.set_time_range('2020-01-12 14:33:10')
    job_instance1.start_instance()

    job_instance1_1 = CimtJobInstance('prefix.to.eliminate.Job 1_1', job_instance1)
    job_instance1_1.set_time_range('2018-08-08', '2018-08-15')
    job_instance1_1.set_value_range(2, 33)
    job_instance1_1.start_instance()
    job_instance1_1.count_input(1111)
    job_instance1_1.count_output(1111)
    job_instance1_1.end_instance()
    print(f"{job_instance1_1.get_work_item()}")

    job_instance1.end_instance_with_error(return_message='This is my error message', return_code=1)

    job_instance2 = CimtJobInstance('Job 2', job_instance_master)
    job_instance2.set_work_item("#This work item should not show up in the table #")
    job_instance2.start_instance()
    print("Job_instance_id", job_instance2.get_job_instance_id())
    print("job_started_at", job_instance2.get_job_started_at())

    prev_job_instance2 = CimtJobInstance('Job 2')
    if prev_job_instance2.load_previous_instance(had_input_data=True):
        print("Prev job_instance_id", prev_job_instance2.get_job_instance_id())
        print("Prev get_count_input", prev_job_instance2.get_count_input())
        print("Prev get_count_output", prev_job_instance2.get_count_output())
        print("Prev get_job_started_at", prev_job_instance2.get_job_started_at())
        print("Prev get_job_ended_at", prev_job_instance2.get_job_ended_at())

    print(f"{job_instance2.get_work_item()}")
    job_instance2.count_input(2222)
    job_instance2.count_rejected(2222)
    job_instance2.count_output(0)
    job_instance2.set_work_item("This work item was set at end")
    job_instance2.set_value_range(None, "Anythin can be a value")
    job_instance2.end_instance()

    job_instance_master.count_ignored(5)
    job_instance_master.end_instance()

    # job_instance_master.start_instance()
    # job_instance_master.end_instance()

    # job_instance_fail = CimtJobInstance(__name__)
    # job_instance_fail.get_job_instance_id()
    # job_instance_fail.end_instance()


if __name__ == '__main__':
    print('Standalone')
    from lib.datamodeldeploymentmanager import DataModelDeploymentManager

    deployment_manager = DataModelDeploymentManager(pg_data_warehouse_getConnection(DwhConnectionType.owner))
    deployment_manager.deploy_table("metadata", "job_instance_status")
    demonstration_and_test_of_CimtJobInstance()

